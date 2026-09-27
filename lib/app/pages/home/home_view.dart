import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/widgets/widgets_export.dart';
import 'home_provider.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: kScreenHorizontalPadding,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Video Room',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Create or join a video room and start calling',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryTextLight,
                ),
              ),
              const SizedBox(height: 36),
              const Center(child: _HeroBadge()),
              const SizedBox(height: 44),
              ActionCard(
                title: 'Create Room',
                subtitle: 'Create a new room and start a video call',
                icon: Icons.add_rounded,
                iconColor: AppColors.primary,
                onTap: notifier.onCreateRoomTap,
              ),
              const SizedBox(height: 16),
              ActionCard(
                title: 'Join Room',
                subtitle: 'Join an existing room using room ID',
                icon: Icons.link_rounded,
                iconColor: AppColors.indigo,
                onTap: notifier.onJoinRoomTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      width: 132,
      decoration: const BoxDecoration(
        color: AppColors.softBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.videocam_rounded,
        size: 58,
        color: AppColors.primary,
      ),
    );
  }
}
