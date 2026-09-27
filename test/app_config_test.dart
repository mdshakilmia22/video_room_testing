import 'dart:io';

import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/data_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app configuration', () {
    test('the app resolves RTC tokens for joining channels', () {
      expect(AgoraConfig.useToken, isTrue);
    });

    test('no freela host is referenced by the api config', () {
      expect(APIConfig.baseUrl, isNot(contains('freela')));
    });

    test('the agora app id is configured', () {
      const defaultAppId = '68b249e23dc6458b9358bd0ba2237b5e';

      if (AgoraConfig.appId == defaultAppId) {
        expect(AgoraConfig.appId, defaultAppId);
        return;
      }
      expect(AgoraConfig.appId, matches(RegExp(r'^[0-9a-f]{32}$')));
    });

    test('the agora app id and certificate have 32 character hex format', () {
      expect(AgoraConfig.appId, matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(AgoraConfig.appCertificate, matches(RegExp(r'^[0-9a-f]{32}$')));
    });

    test('no unapproved certificate is shipped inside the client', () {
      final certificatePattern = RegExp(r'\b[0-9a-f]{32}\b');
      final offenders = <String>[];

      final allowedValues = <String>{
        AgoraConfig.appId,
        AgoraConfig.appCertificate,
      };

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        final code = entity
            .readAsStringSync()
            .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), ' ')
            .replaceAll(RegExp(r'//.*'), ' ');

        final values = certificatePattern
            .allMatches(code)
            .map((m) => m.group(0))
            .where((value) => !allowedValues.contains(value))
            .toSet();

        for (final value in values) {
          offenders.add('${entity.path}: $value');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Unapproved 32-character hex values found in Dart sources:\n'
            '${offenders.join('\n')}',
      );
    });

    test('channels are prefixed with the app channel prefix', () {
      expect(AgoraConfig.channelPrefix, 'video_room');
      expect(RoomRepository().buildChannelName('482319'), 'video_room_482319');
    });

    test('a generated room id is joinable and maps to the same channel', () {
      final repository = RoomRepository();
      final room = repository.createRoom();

      expect(room.roomId, hasLength(RoomRepository.roomIdLength));
      expect(room.channelName, 'video_room_${room.roomId}');

      final joined = repository.joinRoom('#${room.roomId}');
      expect(joined, isNotNull);
      expect(joined!.channelName, room.channelName);
    });

    test('custom room names like test_room are normalized and joinable', () {
      final repository = RoomRepository();
      final joined = repository.joinRoom('test_room');

      expect(joined, isNotNull);
      expect(joined!.roomId, 'test_room');
      expect(joined.channelName, 'test_room');
    });
  });
}
