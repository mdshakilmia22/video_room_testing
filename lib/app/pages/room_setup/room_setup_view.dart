import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/widgets/widgets_export.dart';
import 'package:agora_video_call_test/app/pages/room_setup/components/room_id_display.dart';
import 'package:agora_video_call_test/app/pages/room_setup/components/room_input_field.dart';
import 'package:agora_video_call_test/app/pages/room_setup/components/section_header.dart';
import 'room_setup_provider.dart';
import 'room_setup_state.dart';

class RoomSetupView extends ConsumerStatefulWidget {
  const RoomSetupView({required this.initialMode, super.key});

  final RoomSetupMode initialMode;

  @override
  ConsumerState<RoomSetupView> createState() => _RoomSetupViewState();
}

class _RoomSetupViewState extends ConsumerState<RoomSetupView> {
  late final FocusNode _joinRoomFocusNode;

  @override
  void initState() {
    super.initState();
    _joinRoomFocusNode = FocusNode();
    if (widget.initialMode == RoomSetupMode.join) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _joinRoomFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _joinRoomFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomSetupProvider);
    final notifier = ref.read(roomSetupProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            kScreenHorizontalPadding,
            8,
            kScreenHorizontalPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BackButton(),
              const SizedBox(height: 12),
              const SectionHeader(
                title: 'Create Room',
                description:
                    'Create a new video room and share the room ID with others',
              ),
              const SizedBox(height: 18),
              RoomIdDisplay(
                roomId: state.displayRoomId,
                onCopy: notifier.copyRoomId,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Share this Room ID with others to join',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Start Room',
                icon: Icons.videocam_rounded,
                isLoading: state.isLoading,
                onPressed: notifier.startRoom,
              ),
              const SizedBox(height: 28),
              const OrDivider(),
              const SizedBox(height: 28),
              const SectionHeader(
                title: 'Join Room',
                description: 'Enter the room ID to join an existing video room',
              ),
              const SizedBox(height: 18),
              RoomInputField(
                controller: notifier.joinRoomIdController,
                onChanged: notifier.updateJoinRoomId,
                errorText: state.errorMessage,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Join Room',
                icon: Icons.link_rounded,
                isLoading: state.isLoading,
                onPressed: notifier.joinRoom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(12),
          child: const SizedBox(
            height: 40,
            width: 40,
            child: Icon(
              Icons.chevron_left_rounded,
              size: 30,
              color: AppColors.primaryTextLight,
            ),
          ),
        ),
      ),
    );
  }
}
