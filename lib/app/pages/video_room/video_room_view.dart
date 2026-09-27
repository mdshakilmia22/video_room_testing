import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/data_export.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/call_controls.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/remote_video_canvas.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/room_header.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/self_video_pip.dart';
import 'video_room_provider.dart';

class VideoRoomView extends ConsumerStatefulWidget {
  const VideoRoomView({required this.room, super.key});

  final RoomModel room;

  @override
  ConsumerState<VideoRoomView> createState() => _VideoRoomViewState();
}

class _VideoRoomViewState extends ConsumerState<VideoRoomView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(videoRoomProvider.notifier).init(room: widget.room);
    });
  }

  Future<void> _leave() async {
    await ref.read(videoRoomProvider.notifier).leaveRoom();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoRoomProvider);
    final notifier = ref.read(videoRoomProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _leave();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.videoOverlay,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Full screen background video feed.
              RemoteVideoCanvas(
                remoteUid: state.remoteUid,
                channelName: state.channelName,
                hasRemoteVideo: state.hasRemoteVideo,
              ),
              // Floating self view, top right, slightly below the header.
              SelfVideoPip(isCameraOn: state.isCameraOn),
              // White header bar pinned to the top edge.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: RoomHeader(
                  displayRoomId: state.displayRoomId,
                  participantCount: state.participantCount,
                  onBack: _leave,
                ),
              ),
              // Dark translucent control band pinned to the bottom edge.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CallControls(
                  isMicOn: state.isMicOn,
                  isCameraOn: state.isCameraOn,
                  onToggleMic: notifier.toggleMic,
                  onToggleCamera: notifier.toggleCamera,
                  onLeave: _leave,
                ),
              ),
              if (state.errorMessage != null)
                _ErrorBanner(
                  message: state.errorMessage!,
                  diagnostics: state.diagnostics,
                  onRetry: notifier.retryJoin,
                  onDismiss: notifier.clearError,
                ),
              if (state.isConnecting)
                _ConnectingOverlay(label: state.statusLabel),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectingOverlay extends StatelessWidget {
  const _ConnectingOverlay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(top: topInset + kVideoHeaderHeight),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatefulWidget {
  const _ErrorBanner({
    required this.message,
    required this.diagnostics,
    required this.onRetry,
    required this.onDismiss,
  });

  final String message;
  final String diagnostics;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner> {
  bool _showDiagnostics = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 132),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            decoration: BoxDecoration(
              color: AppColors.red1.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showDiagnostics = !_showDiagnostics),
                      style: _bannerButtonStyle,
                      child: Text(
                        _showDiagnostics ? 'Hide' : 'Details',
                        style: _bannerButtonTextStyle,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onRetry,
                      style: _bannerButtonStyle,
                      child: const Text('Retry', style: _bannerButtonTextStyle),
                    ),
                    IconButton(
                      onPressed: widget.onDismiss,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_showDiagnostics)
                  _DiagnosticsPanel(text: widget.diagnostics),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _bannerButtonTextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

final _bannerButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 10),
  minimumSize: const Size(0, 32),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);

class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                height: 1.4,
                color: Colors.white,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Clipboard.setData(ClipboardData(text: text)),
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Copy'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
