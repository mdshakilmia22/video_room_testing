import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/pages/room_setup/room_setup_state.dart';
import 'package:agora_video_call_test/app/pages/room_setup/room_setup_view.dart';
import 'home_state.dart';

final homeProvider = NotifierProvider.autoDispose<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void onCreateRoomTap() => _openRoomSetup(RoomSetupMode.create);

  void onJoinRoomTap() => _openRoomSetup(RoomSetupMode.join);

  void _openRoomSetup(RoomSetupMode mode) {
    state = state.copyWith(roomSetupMode: mode);
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => RoomSetupView(initialMode: mode)),
    );
  }
}
