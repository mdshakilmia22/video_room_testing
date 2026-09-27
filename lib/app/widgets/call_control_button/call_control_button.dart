import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';

class CallControlButton extends StatelessWidget {
  const CallControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = AppColors.videoControl,
    this.iconColor = Colors.white,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: kControlButtonSize,
            width: kControlButtonSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
