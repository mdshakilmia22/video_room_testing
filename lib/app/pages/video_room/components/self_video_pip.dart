import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/data_export.dart';

class SelfVideoPip extends StatelessWidget {
  const SelfVideoPip({required this.isCameraOn, super.key});

  static const VideoCanvas localCanvas = VideoCanvas(uid: 0);

  final bool isCameraOn;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + kVideoHeaderHeight + 12,
      right: kVideoPipMargin,
      child: GestureDetector(
        onDoubleTap: () =>
            AgoraService().isInitialized ? AgoraService().switchCamera() : null,
        child: Container(
          width: kVideoPipWidth,
          height: kVideoPipHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!isCameraOn) return _cameraOffPlaceholder();
    if (!AgoraService().isInitialized) return _loadingPlaceholder();
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: AgoraService().engine,
        canvas: localCanvas,
      ),
    );
  }

  Widget _cameraOffPlaceholder() {
    return Container(
      color: AppColors.videoSurface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 32,
        color: AppColors.videoMutedText,
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      color: AppColors.videoSurface,
      alignment: Alignment.center,
      child: const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
