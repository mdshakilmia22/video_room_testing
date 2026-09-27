import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/data_export.dart';
import 'package:permission_handler/permission_handler.dart';
import 'video_room_state.dart';

final videoRoomProvider =
    NotifierProvider.autoDispose<VideoRoomNotifier, VideoRoomState>(
      VideoRoomNotifier.new,
    );

const _joinTimeout = Duration(seconds: 15);

class VideoRoomNotifier extends Notifier<VideoRoomState> {
  final _agora = AgoraService();
  final _roomRepo = RoomRepository();

  RoomModel? _room;
  Timer? _joinTimer;
  bool _autoRetried = false;
  bool _isLeaving = false;
  bool _isJoining = false;
  String? _lastAgoraError;

  @override
  VideoRoomState build() {
    ref.onDispose(() {
      _cancelJoinTimeout();
      unawaited(_agora.destroy());
    });
    return const VideoRoomState();
  }

  Future<void> init({required RoomModel room}) async {
    _room = room;
    _autoRetried = false;
    _isLeaving = false;
    _lastAgoraError = null;
    state = state.copyWith(
      roomId: room.roomId,
      channelName: room.channelName,
      localUid: room.localUid,
      isConnecting: true,
      isJoined: false,
      isReconnecting: false,
      clearError: true,
    );

    final cameraGranted = await Permission.camera.request().isGranted;
    final micGranted = await Permission.microphone.request().isGranted;
    if (!ref.mounted) return;

    if (!cameraGranted || !micGranted) {
      state = state.copyWith(
        isConnecting: false,
        errorMessage:
            'Camera and microphone permissions are required for a video room. '
            'If the prompt no longer appears, enable both in the system '
            'settings for Video Room.',
      );
      return;
    }

    await _joinRoom(room);
  }

  Future<void> _leaveHalfJoinedChannel() async {
    if (!_agora.isInitialized) return;
    try {
      await _agora.leaveChannel();
    } catch (_) {
      // Never joined, nothing to leave.
    }
  }

  Future<void> _joinRoom(RoomModel room) async {
    if (_isJoining) return;
    _isJoining = true;

    state = state.copyWith(
      isConnecting: true,
      isJoined: false,
      isReconnecting: false,
      clearError: true,
    );

    String? token;
    try {
      token = await _roomRepo.resolveToken(
        channelName: room.channelName,
        uid: room.localUid,
      );
      if (!ref.mounted) return;

      await _leaveHalfJoinedChannel();

      await _agora.initialize();
      _registerEventHandler();
      await _agora.startVideoRoom(
        channelId: room.channelName,
        uid: room.localUid,
        token: token,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isConnecting: false,
        errorMessage: 'Unable to join the room: $e',
      );
      return;
    } finally {
      _isJoining = false;
    }

    if (!ref.mounted) return;
    _startJoinTimeout(room);
  }

  void _startJoinTimeout(RoomModel room) {
    _cancelJoinTimeout();
    _joinTimer = Timer(_joinTimeout, () {
      if (!ref.mounted || state.isJoined) return;
      state = state.copyWith(
        isConnecting: false,
        errorMessage:
            'Could not reach room #${room.roomId} within 15 seconds. '
            'Check the internet connection on this device. If the Agora '
            'project has an App Certificate enabled, the app also needs an '
            'RTC token (AgoraConfig.useToken), which requires a token server.',
      );
    });
  }

  void _cancelJoinTimeout() {
    _joinTimer?.cancel();
    _joinTimer = null;
  }

  void _registerEventHandler() {
    _agora.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          _cancelJoinTimeout();
          _autoRetried = false;
          _lastAgoraError = null;
          if (!ref.mounted) return;
          debugPrint(
            '[Agora] Joined ${connection.channelId} as uid '
            '${connection.localUid} in ${elapsed}ms',
          );
          state = state.copyWith(
            isConnecting: false,
            isJoined: true,
            isReconnecting: false,
            localUid: connection.localUid,
            clearError: true,
          );
        },
        onRejoinChannelSuccess: (connection, elapsed) {
          _cancelJoinTimeout();
          if (!ref.mounted) return;
          debugPrint('[Agora] Rejoined ${connection.channelId}');
          state = state.copyWith(
            isConnecting: false,
            isJoined: true,
            isReconnecting: false,
            clearError: true,
          );
        },
        onLeaveChannel: (connection, stats) {
          if (!ref.mounted || _isLeaving) return;
          // The SDK removes the local user from the channel on its own when the
          // server rejects the uid, which is the usual reason two phones never
          // end up together.
          debugPrint(
            '[Agora] The SDK removed this device from ${connection.channelId}',
          );
          state = state.copyWith(
            isConnecting: false,
            isJoined: false,
            errorMessage:
                'This device was removed from room #${state.roomId} by the '
                'Agora server. This usually means the uid is already in use, '
                'or the project requires a token. Tap Retry.',
          );
        },
        onConnectionStateChanged: (connection, connectionState, reason) {
          if (!ref.mounted) return;
          debugPrint(
            '[Agora] connection state of ${connection.channelId} changed to '
            '$connectionState ($reason)',
          );
          switch (connectionState) {
            case ConnectionStateType.connectionStateConnected:
              _cancelJoinTimeout();
              _autoRetried = false;
              _lastAgoraError = null;
              state = state.copyWith(
                isConnecting: false,
                isJoined: true,
                isReconnecting: false,
                clearError: true,
              );
            case ConnectionStateType.connectionStateConnecting:
              state = state.copyWith(isConnecting: true, isJoined: false);
            case ConnectionStateType.connectionStateReconnecting:
              state = state.copyWith(
                isConnecting: true,
                isJoined: false,
                isReconnecting: true,
              );
            case ConnectionStateType.connectionStateDisconnected:
              _cancelJoinTimeout();
              state = state.copyWith(
                isConnecting: false,
                isJoined: false,
                isReconnecting: false,
              );
            case ConnectionStateType.connectionStateFailed:
              _cancelJoinTimeout();
              state = state.copyWith(
                isConnecting: false,
                isJoined: false,
                isReconnecting: false,
              );

              final room = _room;
              if (!_autoRetried && room != null && !_isLeaving) {
                _autoRetried = true;
                debugPrint('[Agora] connection failed, rejoining once');
                unawaited(_joinRoom(room));
              } else if (room != null) {
                state = state.copyWith(
                  errorMessage:
                      _lastAgoraError ??
                      'The Agora server refused the connection to room '
                          '#${room.roomId}. Check that the Agora project needs '
                          'no token, that App ID ${AgoraConfig.appId} is '
                          'correct and active, and that this device is online.',
                  rawAgoraError: _lastAgoraError != null
                      ? null
                      : 'connectionStateFailed '
                            '(the SDK reported no error code)',
                );
              }
          }
        },
        onError: (err, msg) {
          if (!ref.mounted) return;
          debugPrint('[Agora] error ${err.name}: $msg');
          _lastAgoraError = _describeAgoraError(err, msg);
          state = state.copyWith(
            isConnecting: false,
            isJoined: false,
            errorMessage: _lastAgoraError,
            rawAgoraError: '${err.name}: $msg',
          );
        },
        onLocalUserRegistered: (uid, userAccount) {
          if (!ref.mounted) return;
          state = state.copyWith(localUid: uid);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (!ref.mounted) return;
          debugPrint(
            '[Agora] user ${connection.channelId}/$remoteUid joined '
            '(local uid ${state.localUid})',
          );
          state = state.copyWith(
            remoteUid: remoteUid,
            isRemoteVideoOn: true,
            clearError: true,
          );
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (!ref.mounted) return;
          debugPrint('[Agora] user $remoteUid left ${connection.channelId}');
          if (state.remoteUid != remoteUid) return;
          state = state.copyWith(clearRemote: true);
        },
        onRemoteVideoStateChanged:
            (connection, remoteUid, videoState, reason, elapsed) {
              if (!ref.mounted) return;
              final isOn =
                  videoState == RemoteVideoState.remoteVideoStateDecoding;
              state = state.copyWith(isRemoteVideoOn: isOn);
            },
      ),
    );
  }

  String _describeAgoraError(ErrorCodeType err, String msg) {
    switch (err) {
      case ErrorCodeType.errInvalidAppId:
        return 'Agora rejected the App ID. Check AgoraConfig.appId and make '
            'sure the Agora project is active.';
      case ErrorCodeType.errInvalidToken:
      case ErrorCodeType.errTokenExpired:
        return 'Agora refused the empty token, which means the project behind '
            'App ID ${AgoraConfig.appId} has an App Certificate enabled. This '
            'app has no backend, so it cannot mint one. Fix it in the Agora '
            'console: either disable the App Certificate of that project, or '
            'point the app at a different project that has no certificate. ($msg)';
      case ErrorCodeType.errInvalidChannelName:
        return 'The channel name was rejected by Agora. It has to be '
            'video_room_ followed by 6 digits. ($msg)';
      case ErrorCodeType.errJoinChannelRejected:
        return 'Agora rejected the join because this device is already in the '
            'channel. Tap Retry, the app leaves the old channel first. ($msg)';
      case ErrorCodeType.errClientIsBannedByServer:
        return 'This device was removed from the channel by the Agora server. '
            '($msg)';
      case ErrorCodeType.errNoPermission:
      case ErrorCodeType.errNotInChannel:
        return 'Agora refused the call because of the connection state. Leave '
            'the room and join again. ($msg)';
      default:
        return 'Agora error ${err.name}: $msg';
    }
  }

  /// Re-requests the room after a failed or lost connection.
  Future<void> retryJoin() async {
    final room = _room;
    if (room == null) return;
    _autoRetried = false;
    await _joinRoom(room);
  }

  void toggleMic() {
    final isMicOn = !state.isMicOn;
    state = state.copyWith(isMicOn: isMicOn);
    _muteAudio(!isMicOn);
  }

  void toggleCamera() {
    final isCameraOn = !state.isCameraOn;
    state = state.copyWith(isCameraOn: isCameraOn);
    _muteVideo(!isCameraOn);
  }

  void switchCamera() {
    if (!state.isCameraOn) return;
    unawaited(_agora.switchCamera());
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> leaveRoom() async {
    _cancelJoinTimeout();
    final room = _room;
    _room = null;
    _isLeaving = true;
    state = state.copyWith(
      isJoined: false,
      isConnecting: false,
      isReconnecting: false,
    );
    if (room == null) return;
    try {
      await _agora.leaveChannel();
    } catch (_) {}
    await _agora.destroy();
  }

  void _muteAudio(bool mute) {
    if (!_agora.isInitialized) {
      debugPrint('[Agora] Audio toggle ignored, engine not ready');
      return;
    }
    unawaited(_agora.muteLocalAudioStream(mute));
  }

  void _muteVideo(bool mute) {
    if (!_agora.isInitialized) {
      debugPrint('[Agora] Video toggle ignored, engine not ready');
      return;
    }
    unawaited(_agora.muteLocalVideoStream(mute));
  }
}
