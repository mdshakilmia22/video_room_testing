import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/data_export.dart';
import 'package:agora_video_call_test/app/pages/video_room/video_room_view.dart';
import 'room_setup_state.dart';

final roomSetupProvider =
    NotifierProvider.autoDispose<RoomSetupNotifier, RoomSetupState>(
      RoomSetupNotifier.new,
    );

class RoomSetupNotifier extends Notifier<RoomSetupState> {
  final _roomRepo = RoomRepository();

  late final TextEditingController joinRoomIdController;
  late RoomModel _room;

  @override
  RoomSetupState build() {
    joinRoomIdController = TextEditingController();
    ref.onDispose(() => joinRoomIdController.dispose());

    _room = _roomRepo.createRoom();
    return RoomSetupState(roomId: _room.roomId, channelName: _room.channelName);
  }

  void generateNewRoom() {
    _room = _roomRepo.createRoom();
    state = state.copyWith(
      roomId: _room.roomId,
      channelName: _room.channelName,
      clearError: true,
    );
  }

  void updateJoinRoomId(String value) =>
      state = state.copyWith(joinRoomId: value, clearError: true);

  Future<void> copyRoomId() async {
    await Clipboard.setData(ClipboardData(text: state.roomId));
    if (!ref.mounted) return;
    await EasyLoading.showSuccess('Room ID copied');
  }

  Future<bool> startRoom() => _openRoom(_room);

  Future<bool> joinRoom() async {
    final room = _roomRepo.joinRoom(state.joinRoomId);
    if (room == null) {
      state = state.copyWith(
        errorMessage:
            'Enter a valid ${RoomRepository.roomIdLength} digit room ID',
      );
      return false;
    }
    return _openRoom(room);
  }

  Future<bool> _openRoom(RoomModel room) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await appNavigatorKey.currentState?.push<bool>(
      MaterialPageRoute(builder: (_) => VideoRoomView(room: room)),
    );
    if (!ref.mounted) return false;
    state = state.copyWith(isLoading: false);
    return true;
  }
}
