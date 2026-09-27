import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';

class RoomIdDisplay extends StatelessWidget {
  const RoomIdDisplay({required this.roomId, required this.onCopy, super.key});

  final String roomId;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tag_rounded,
            size: 20,
            color: AppColors.secondaryTextLight,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Room ID',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roomId,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: AppColors.primaryTextLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                height: 42,
                width: 42,
                child: Icon(Icons.copy_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
