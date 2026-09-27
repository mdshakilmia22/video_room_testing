import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/widgets/widgets_export.dart';

class CallControls extends StatelessWidget {
  const CallControls({
    required this.isMicOn,
    required this.isCameraOn,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onLeave,
    super.key,
  });

  final bool isMicOn;
  final bool isCameraOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.72),
            Colors.black.withValues(alpha: 0.45),
            Colors.transparent,
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CallControlButton(
                  icon: isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                  label: 'Mic',
                  onTap: onToggleMic,
                ),
                CallControlButton(
                  icon: isCameraOn
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  label: 'Camera',
                  onTap: onToggleCamera,
                ),
                CallControlButton(
                  icon: Icons.call_end_rounded,
                  label: 'Leave',
                  backgroundColor: AppColors.red1,
                  onTap: onLeave,
                ),
              ],
            ),
          ),
          // Sits outside of the SafeArea so it stays flush with the bottom
          // edge of the screen, like the iOS home indicator.
          const _SwipeIndicator(),
        ],
      ),
    );
  }
}

class _SwipeIndicator extends StatelessWidget {
  const _SwipeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
