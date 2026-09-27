import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

import 'package:agora_video_call_test/app/core/core_export.dart';

class AgoraService {
  AgoraService._();

  static final AgoraService _instance = AgoraService._();

  factory AgoraService() => _instance;

  RtcEngine? _engine;
  bool _initialized = false;
  RtcEngineEventHandler? _eventHandler;

  RtcEngine get engine {
    if (_engine == null) {
      throw StateError(
        'Agora engine not initialized. Call initialize() first.',
      );
    }
    return _engine!;
  }

  bool get isInitialized => _initialized;

  Future<RtcEngine> initialize() async {
    if (_initialized && _engine != null) return _engine!;

    final engine = createAgoraRtcEngine();
    try {
      await engine.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
    } catch (e) {
      // Never leave a half built engine behind, otherwise the next
      // initialize() would reuse a broken instance.
      try {
        engine.release();
      } catch (_) {}
      _engine = null;
      _initialized = false;
      rethrow;
    }

    _engine = engine;
    _initialized = true;
    debugPrint('[Agora] Engine initialized for app id ${AgoraConfig.appId}');
    return engine;
  }

  void registerEventHandler(RtcEngineEventHandler handler) {
    _eventHandler = handler;
    engine.registerEventHandler(handler);
  }

  Future<void> startVideoRoom({
    required String channelId,
    required int uid,
    String? token,
  }) async {
    await engine.enableVideo();
    await engine.enableAudio();
    await engine.setAudioScenario(AudioScenarioType.audioScenarioDefault);
    await engine.startPreview();

    const channelOptions = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      publishCameraTrack: true,
      publishMicrophoneTrack: true,
      autoSubscribeVideo: true,
      autoSubscribeAudio: true,
    );

    await engine.joinChannel(
      token: (token != null && token.isNotEmpty) ? token : '',
      channelId: channelId,
      options: channelOptions,
      uid: uid,
    );
    debugPrint('[Agora] Joined video channel: $channelId as uid: $uid');
  }

  Future<void> muteLocalVideoStream(bool mute) =>
      engine.muteLocalVideoStream(mute);

  Future<void> muteLocalAudioStream(bool mute) =>
      engine.muteLocalAudioStream(mute);

  Future<void> enableLocalVideo(bool enabled) =>
      engine.enableLocalVideo(enabled);

  Future<void> setEnableSpeakerphone(bool enabled) =>
      engine.setEnableSpeakerphone(enabled);

  Future<void> switchCamera() => engine.switchCamera();

  Future<void> leaveChannel() async {
    if (_initialized) await engine.leaveChannel();
  }

  Future<void> destroy() async {
    if (_engine != null) {
      try {
        await engine.leaveChannel();
      } catch (_) {}
      if (_eventHandler != null) {
        try {
          engine.unregisterEventHandler(_eventHandler!);
        } catch (_) {}
      }
      _eventHandler = null;
      engine.release();
      _engine = null;
      _initialized = false;
      debugPrint('[Agora] Engine released');
    }
  }
}
