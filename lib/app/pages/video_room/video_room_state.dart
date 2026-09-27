import 'package:flutter/foundation.dart';

import '../../core/core_export.dart';

class VideoRoomState {
  const VideoRoomState({
    this.roomId = '',
    this.channelName = '',
    this.localUid = 0,
    this.remoteUid,
    this.isConnecting = true,
    this.isJoined = false,
    this.isReconnecting = false,
    this.isMicOn = true,
    this.isCameraOn = true,
    this.isRemoteVideoOn = true,
    this.errorMessage,
    this.rawAgoraError,
  });

  final String roomId;
  final String channelName;
  final int localUid;
  final int? remoteUid;

  final bool isConnecting;

  final bool isJoined;

  final bool isReconnecting;

  final bool isMicOn;
  final bool isCameraOn;
  final bool isRemoteVideoOn;
  final String? errorMessage;

  final String? rawAgoraError;

  String get diagnostics => [
    'App ID in use : ${AgoraConfig.appId}',
    'Token used   : ${AgoraConfig.useToken ? 'yes' : 'no'}',
    'Channel      : $channelName',
    'Local UID    : $localUid',
    'Joined       : ${isJoined ? 'yes' : 'no'}',
    'SDK error    : ${rawAgoraError ?? 'none'}',
    'Build        : ${kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug'}',
  ].join('\n');

  String get displayRoomId => roomId.isEmpty ? '#------' : '#$roomId';

  int get participantCount {
    if (!isJoined) return 0;
    return remoteUid != null ? 2 : 1;
  }

  bool get hasRemoteVideo => remoteUid != null && isRemoteVideoOn;

  String get statusLabel =>
      isReconnecting ? 'Reconnecting to room...' : 'Connecting to room...';

  VideoRoomState copyWith({
    String? roomId,
    String? channelName,
    int? localUid,
    int? remoteUid,
    bool? isConnecting,
    bool? isJoined,
    bool? isReconnecting,
    bool? isMicOn,
    bool? isCameraOn,
    bool? isRemoteVideoOn,
    String? errorMessage,
    String? rawAgoraError,
    bool clearError = false,
    bool clearRemote = false,
  }) {
    return VideoRoomState(
      roomId: roomId ?? this.roomId,
      channelName: channelName ?? this.channelName,
      localUid: localUid ?? this.localUid,
      remoteUid: clearRemote ? null : (remoteUid ?? this.remoteUid),
      isConnecting: isConnecting ?? this.isConnecting,
      isJoined: isJoined ?? this.isJoined,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      isMicOn: isMicOn ?? this.isMicOn,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isRemoteVideoOn: isRemoteVideoOn ?? this.isRemoteVideoOn,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      rawAgoraError: clearError ? null : (rawAgoraError ?? this.rawAgoraError),
    );
  }
}
