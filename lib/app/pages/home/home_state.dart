import 'package:agora_video_call_test/app/pages/room_setup/room_setup_state.dart';

class HomeState {
  const HomeState({this.roomSetupMode = RoomSetupMode.create});

  final RoomSetupMode roomSetupMode;

  HomeState copyWith({RoomSetupMode? roomSetupMode}) {
    return HomeState(roomSetupMode: roomSetupMode ?? this.roomSetupMode);
  }
}
