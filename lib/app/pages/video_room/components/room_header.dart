import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({
    required this.displayRoomId,
    required this.participantCount,
    required this.onBack,
    super.key,
  });

  final String displayRoomId;
  final int participantCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.primaryContainerColor,
      padding: EdgeInsets.only(top: topInset),
      child: Container(
        height: kVideoHeaderHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border2)),
        ),
        child: Row(
          children: [
            _HeaderIconButton(icon: Icons.chevron_left_rounded, onTap: onBack),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Video Room',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayRoomId,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryTextLight,
                    ),
                  ),
                ],
              ),
            ),
            _ParticipantCount(count: participantCount),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, size: 26, color: AppColors.primaryTextLight),
        ),
      ),
    );
  }
}

class _ParticipantCount extends StatelessWidget {
  const _ParticipantCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.people_alt_rounded,
          size: 20,
          color: AppColors.secondaryTextLight,
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          constraints: const BoxConstraints(minWidth: 20),
          decoration: BoxDecoration(
            color: AppColors.kBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryTextLight,
            ),
          ),
        ),
      ],
    );
  }
}
