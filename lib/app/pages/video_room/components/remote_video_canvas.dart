import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/data_export.dart';

class RemoteVideoCanvas extends StatelessWidget {
  const RemoteVideoCanvas({
    required this.remoteUid,
    required this.channelName,
    required this.hasRemoteVideo,
    super.key,
  });

  final int? remoteUid;
  final String channelName;
  final bool hasRemoteVideo;

  @override
  Widget build(BuildContext context) {
    final uid = remoteUid;
    final canRender = uid != null && uid != 0 && AgoraService().isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (canRender)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: AgoraService().engine,
              canvas: VideoCanvas(uid: uid),
              connection: RtcConnection(channelId: channelName),
            ),
          )
        else
          const ColoredBox(color: AppColors.videoPlaceholder),
        if (!hasRemoteVideo) _Overlay(isWaiting: uid == null),
      ],
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.isWaiting});

  final bool isWaiting;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.videoPlaceholder,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: const BoxDecoration(
                color: AppColors.videoSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: AppColors.secondaryTextLight,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isWaiting ? 'Waiting for others to join...' : 'Camera is off',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.videoMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
