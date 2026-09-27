import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryTextLight),
        ),
      ],
    );
  }
}
