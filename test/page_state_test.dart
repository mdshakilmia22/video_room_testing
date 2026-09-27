import 'package:agora_video_call_test/app/pages/room_setup/room_setup_state.dart';
import 'package:agora_video_call_test/app/pages/video_room/video_room_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoomSetupState', () {
    test('falls back to a placeholder while no room id is known', () {
      expect(const RoomSetupState().displayRoomId, '------');
      expect(const RoomSetupState(roomId: '482319').displayRoomId, '482319');
    });

    test('copyWith keeps the previous values', () {
      const state = RoomSetupState(roomId: '482319', joinRoomId: '111222');

      final copy = state.copyWith(joinRoomId: '333444');

      expect(copy.roomId, '482319');
      expect(copy.joinRoomId, '333444');
    });

    test('clearError removes the error message', () {
      const state = RoomSetupState(errorMessage: 'Enter a valid room ID');

      expect(state.copyWith().errorMessage, isNotNull);
      expect(state.copyWith(clearError: true).errorMessage, isNull);
    });
  });

  group('VideoRoomState', () {
    test('formats the room id with a leading hash', () {
      expect(const VideoRoomState().displayRoomId, '#------');
      expect(const VideoRoomState(roomId: '482319').displayRoomId, '#482319');
    });

    test('counts no participant before joining the channel', () {
      expect(const VideoRoomState().participantCount, 0);
    });

    test(
      'a room with a remote user is not joined until the sdk confirms it',
      () {
        // onUserJoined can fire for a peer that is not reachable, so the count
        // must stay at 0 while isJoined is false.
        const state = VideoRoomState(isJoined: false, remoteUid: 42);
        expect(state.participantCount, 0);
        expect(state.hasRemoteVideo, isTrue);
      },
    );

    test('status label distinguishes connecting from reconnecting', () {
      expect(
        const VideoRoomState(isConnecting: true).statusLabel,
        'Connecting to room...',
      );
      expect(
        const VideoRoomState(
          isConnecting: true,
          isReconnecting: true,
        ).statusLabel,
        'Reconnecting to room...',
      );
    });

    test('copyWith can clear the reconnecting flag', () {
      const state = VideoRoomState(isReconnecting: true, isJoined: false);

      final reconnected = state.copyWith(
        isConnecting: false,
        isJoined: true,
        isReconnecting: false,
      );

      expect(reconnected.isReconnecting, isFalse);
      expect(reconnected.isJoined, isTrue);
      expect(reconnected.isConnecting, isFalse);
    });

    test('counts the local user once joined', () {
      const state = VideoRoomState(isJoined: true);

      expect(state.participantCount, 1);
    });

    test('counts both users once a remote user joined', () {
      const state = VideoRoomState(isJoined: true, remoteUid: 42);

      expect(state.participantCount, 2);
    });

    test('remote video needs a remote uid and a published video', () {
      expect(
        const VideoRoomState(isRemoteVideoOn: true).hasRemoteVideo,
        isFalse,
      );
      expect(const VideoRoomState(remoteUid: 42).hasRemoteVideo, isTrue);
      expect(
        const VideoRoomState(
          remoteUid: 42,
          isRemoteVideoOn: false,
        ).hasRemoteVideo,
        isFalse,
      );
    });

    test('clearRemote drops the remote uid', () {
      const state = VideoRoomState(remoteUid: 42);

      final copy = state.copyWith(clearRemote: true);

      expect(copy.remoteUid, isNull);
      expect(copy.participantCount, 0);
    });

    test('clearError drops the error message', () {
      const state = VideoRoomState(errorMessage: 'Permission denied');

      expect(state.copyWith(clearError: true).errorMessage, isNull);
    });
  });
}
