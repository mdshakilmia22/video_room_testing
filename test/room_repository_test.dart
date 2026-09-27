import 'package:agora_video_call_test/app/data/data_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = RoomRepository();

  group('RoomRepository room id', () {
    test('creates a room with a 6 digit room id', () {
      final room = repository.createRoom();

      expect(room.roomId, hasLength(RoomRepository.roomIdLength));
      expect(room.roomId, matches(RegExp(r'^\d{6}$')));
      expect(int.parse(room.roomId), greaterThanOrEqualTo(100000));
      expect(int.parse(room.roomId), lessThanOrEqualTo(999999));
    });

    test('creates a room with a unique local uid', () {
      final uids = <int>{
        for (var i = 0; i < 50; i++) repository.createRoom().localUid,
      };

      expect(uids.length, 50);
      expect(uids.every((uid) => uid > 0), isTrue);
    });

    test('builds an agora safe channel name out of the room id', () {
      final room = repository.createRoom();

      expect(room.channelName, 'video_room_${room.roomId}');
      expect(room.channelName, matches(RegExp(r'^[a-z0-9_]+$')));
    });

    test('createRoom returns different rooms on every call', () {
      final rooms = {
        for (var i = 0; i < 50; i++) repository.createRoom().roomId,
      };

      expect(rooms.length, greaterThan(1));
    });
  });

  group('RoomRepository.normalizeRoomId', () {
    test('accepts a valid room id', () {
      expect(repository.normalizeRoomId('482319'), '482319');
      expect(repository.normalizeRoomId('  482319  '), '482319');
      expect(repository.normalizeRoomId('#482319'), '482319');
    });

    test('rejects ids with a wrong length', () {
      expect(repository.normalizeRoomId(''), isNull);
      expect(repository.normalizeRoomId('12345'), isNull);
      expect(repository.normalizeRoomId('1234567'), isNull);
    });

    test('rejects ids that are not numeric only', () {
      expect(repository.normalizeRoomId('abcde'), isNull);
      expect(repository.normalizeRoomId('12a456'), isNull);
    });
  });

  group('RoomRepository.joinRoom', () {
    test('builds the room of an existing room id', () {
      final room = repository.joinRoom('482319');

      expect(room, isNotNull);
      expect(room!.roomId, '482319');
      expect(room.channelName, 'video_room_482319');
    });

    test('returns null for an invalid room id', () {
      expect(repository.joinRoom('12345'), isNull);
      expect(repository.joinRoom('not-a-room'), isNull);
    });
  });

  group('RoomModel', () {
    test('exposes the room id with a leading hash', () {
      final room = repository.joinRoom('482319')!;

      expect(room.displayRoomId, '#482319');
    });

    test('copyWith only replaces the given values', () {
      final room = repository.createRoom();
      final copy = room.copyWith(roomId: '111222');

      expect(copy.roomId, '111222');
      expect(copy.channelName, room.channelName);
      expect(copy.localUid, room.localUid);
      expect(copy.createdAt, room.createdAt);
    });
  });
}
