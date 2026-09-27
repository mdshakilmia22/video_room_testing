import 'dart:math';

import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/model/room_model.dart';
import 'package:agora_video_call_test/app/data/services/services_export.dart';

class RoomRepository {
  RoomRepository._();

  static final RoomRepository _instance = RoomRepository._();

  factory RoomRepository() => _instance;

  final _client = ApiClient();
  final _random = Random();

  static const int roomIdLength = 6;
  static const int minRoomId = 100000;
  static const int maxRoomId = 999999;

  RoomModel createRoom() {
    final roomId = _generateRoomId();
    return RoomModel(
      roomId: roomId,
      channelName: buildChannelName(roomId),
      localUid: generateUid(),
      createdAt: DateTime.now(),
    );
  }

  RoomModel? joinRoom(String rawRoomId) {
    final roomId = normalizeRoomId(rawRoomId);
    if (roomId == null) return null;
    return RoomModel(
      roomId: roomId,
      channelName: buildChannelName(roomId),
      localUid: generateUid(),
      createdAt: DateTime.now(),
    );
  }

  String? normalizeRoomId(String rawRoomId) {
    final trimmed = rawRoomId.trim();
    if (trimmed.isEmpty) return null;

    final sanitized = trimmed.replaceAll(RegExp(r'^[#_]+'), '');

    // 1. Numeric 6-digit room ID (e.g., 482319 or #482319)
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (RegExp(r'^\s*#?\s*\d+\s*$').hasMatch(trimmed) ||
        digitsOnly.length == trimmed.length) {
      if (digitsOnly.length == roomIdLength) {
        final value = int.tryParse(digitsOnly);
        if (value != null && value >= minRoomId && value <= maxRoomId) {
          return digitsOnly;
        }
      }
      return null;
    }

    // 2. Custom room/channel name (e.g. test_room or video_room_123456)
    if (sanitized == 'test_room' ||
        sanitized.startsWith('${AgoraConfig.channelPrefix}_')) {
      return sanitized;
    }

    return null;
  }

  String buildChannelName(String roomId) {
    if (roomId.startsWith('${AgoraConfig.channelPrefix}_')) {
      return roomId;
    }
    // If numeric 6-digit room ID, prefix with app channelPrefix
    if (RegExp(r'^\d{6}$').hasMatch(roomId)) {
      return '${AgoraConfig.channelPrefix}_$roomId';
    }
    // Custom room/channel name (e.g. test_room) used directly
    return roomId;
  }

  int generateUid() => _random.nextInt(maxRoomId) + minRoomId;

  Future<String?> resolveToken({
    required String channelName,
    required int uid,
  }) async {
    if (!AgoraConfig.useToken) return null;

    // 1. Client-side token generation using App Certificate
    if (AgoraConfig.appCertificate.isNotEmpty) {
      final generated = AgoraTokenGenerator.generateRtcToken(
        appId: AgoraConfig.appId,
        appCertificate: AgoraConfig.appCertificate,
        channelName: channelName,
        uid: uid,
      );
      if (generated.isNotEmpty) return generated;
    }

    // 2. Temp token override / fallback if available
    if (AgoraConfig.tempToken.isNotEmpty) {
      return AgoraConfig.tempToken;
    }

    // 3. Fallback to API server call if configured
    try {
      final response = await _client.api.post(
        APIConfig.agoraTokenUrl,
        body: {'channel_name': channelName, 'uid': uid},
      );
      final data = response['data'];
      if (data is Map<String, dynamic>) return data['token'] as String?;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _generateRoomId() =>
      (_random.nextInt(maxRoomId - minRoomId + 1) + minRoomId).toString();
}
