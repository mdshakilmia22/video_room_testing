import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class AgoraTokenGenerator {
  AgoraTokenGenerator._();

  static String generateRtcToken({
    required String appId,
    required String appCertificate,
    required String channelName,
    required int uid,
    int expireSeconds = 86400,
  }) {
    if (appId.isEmpty || appCertificate.isEmpty) return '';

    final issueTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTs = issueTs + expireSeconds;
    final salt = (DateTime.now().microsecondsSinceEpoch & 0xFFFFFFFF);

    // Build Payload bytes
    final payloadBuilder = BytesBuilder();

    // 1. App ID string (uint16 length + UTF8 bytes)
    final appIdBytes = utf8.encode(appId);
    final appIdLenBd = ByteData(2)
      ..setUint16(0, appIdBytes.length, Endian.little);
    payloadBuilder.add(appIdLenBd.buffer.asUint8List());
    payloadBuilder.add(appIdBytes);

    // 2. issueTs (uint32 LE)
    final issueTsBd = ByteData(4)..setUint32(0, issueTs, Endian.little);
    final issueTsBytes = issueTsBd.buffer.asUint8List();
    payloadBuilder.add(issueTsBytes);

    // 3. expire (uint32 LE, e.g. 86400)
    final expireBd = ByteData(4)..setUint32(0, expireSeconds, Endian.little);
    payloadBuilder.add(expireBd.buffer.asUint8List());

    // 4. salt (uint32 LE)
    final saltBd = ByteData(4)..setUint32(0, salt, Endian.little);
    final saltBytes = saltBd.buffer.asUint8List();
    payloadBuilder.add(saltBytes);

    // 5. serviceCount (uint16 LE) = 1
    final serviceCountBd = ByteData(2)..setUint16(0, 1, Endian.little);
    payloadBuilder.add(serviceCountBd.buffer.asUint8List());

    // Service 1: ServiceRtc (type = 1)
    final serviceTypeBd = ByteData(2)..setUint16(0, 1, Endian.little);
    payloadBuilder.add(serviceTypeBd.buffer.asUint8List());

    // Privileges count = 3 (JoinChannel, PublishAudio, PublishVideo)
    final privCountBd = ByteData(2)..setUint16(0, 3, Endian.little);
    payloadBuilder.add(privCountBd.buffer.asUint8List());

    // Privilege expire timestamp (issueTs + expireSeconds)
    final privExpireBd = ByteData(4)..setUint32(0, expireTs, Endian.little);

    // Priv 1: kPrivilegeJoinChannel (1)
    final priv1Bd = ByteData(2)..setUint16(0, 1, Endian.little);
    payloadBuilder.add(priv1Bd.buffer.asUint8List());
    payloadBuilder.add(privExpireBd.buffer.asUint8List());

    // Priv 2: kPrivilegePublishAudioStream (2)
    final priv2Bd = ByteData(2)..setUint16(0, 2, Endian.little);
    payloadBuilder.add(priv2Bd.buffer.asUint8List());
    payloadBuilder.add(privExpireBd.buffer.asUint8List());

    // Priv 3: kPrivilegePublishVideoStream (3)
    final priv3Bd = ByteData(2)..setUint16(0, 3, Endian.little);
    payloadBuilder.add(priv3Bd.buffer.asUint8List());
    payloadBuilder.add(privExpireBd.buffer.asUint8List());

    // Channel name string (uint16 length + UTF8 bytes)
    final channelBytes = utf8.encode(channelName);
    final channelLenBd = ByteData(2)
      ..setUint16(0, channelBytes.length, Endian.little);
    payloadBuilder.add(channelLenBd.buffer.asUint8List());
    payloadBuilder.add(channelBytes);

    // Uid string (uint16 length + UTF8 bytes)
    // In Agora AccessToken2, empty string "" acts as a wildcard UID 0 (matches any UID)
    final uidStr = uid == 0 ? '' : uid.toString();
    final uidBytes = utf8.encode(uidStr);
    final uidLenBd = ByteData(2)..setUint16(0, uidBytes.length, Endian.little);
    payloadBuilder.add(uidLenBd.buffer.asUint8List());
    payloadBuilder.add(uidBytes);

    final payload = payloadBuilder.toBytes();

    // Calculate Signature using AccessToken2 formula:
    // kB1 = HMAC-SHA256(key: issueTsBytes, data: certBytes)
    // kB2 = HMAC-SHA256(key: saltBytes, data: kB1)
    // signature = HMAC-SHA256(key: kB2, data: payload)
    final certBytes = utf8.encode(appCertificate);
    final kB1 = Hmac(sha256, issueTsBytes).convert(certBytes).bytes;
    final kB2 = Hmac(sha256, saltBytes).convert(kB1).bytes;
    final signature = Hmac(sha256, kB2).convert(payload).bytes;

    // Full token bytes = uint16(sig.length) + signature (32 bytes) + payload
    final fullTokenBuilder = BytesBuilder();
    final sigLenBd = ByteData(2)..setUint16(0, signature.length, Endian.little);
    fullTokenBuilder.add(sigLenBd.buffer.asUint8List());
    fullTokenBuilder.add(signature);
    fullTokenBuilder.add(payload);

    final compressed = zlib.encode(fullTokenBuilder.toBytes());
    return '007${base64.encode(compressed)}';
  }
}
