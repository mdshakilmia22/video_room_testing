import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:agora_video_call_test/app/data/services/services_export.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates valid Agora AccessToken2 structure and signature', () {
    const appId = '68b249e23dc6458b9358bd0ba2237b5e';
    const appCertificate = '802a873815d04b97a82add7946ac1bfc';
    const channelName = 'video_room_224876';
    const uid = 639332;

    final token = AgoraTokenGenerator.generateRtcToken(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: uid,
    );

    expect(token, startsWith('007'));
    expect(token.length, greaterThan(50));

    // Verify token structure
    final rawBytes = base64.decode(token.substring(3));
    final decompressed = Uint8List.fromList(zlib.decode(rawBytes));
    final bd = ByteData.sublistView(decompressed);

    final sigLen = bd.getUint16(0, Endian.little);
    expect(sigLen, 32);

    final sig = decompressed.sublist(2, 2 + sigLen);
    final payload = decompressed.sublist(2 + sigLen);

    // Parse payload
    final pBd = ByteData.sublistView(payload);
    int offset = 0;

    final appIdLen = pBd.getUint16(offset, Endian.little);
    offset += 2;
    final parsedAppId = utf8.decode(payload.sublist(offset, offset + appIdLen));
    offset += appIdLen;
    expect(parsedAppId, appId);

    final issueTsBytes = payload.sublist(offset, offset + 4);
    offset += 4; // issueTs

    offset += 4; // expire

    final saltBytes = payload.sublist(offset, offset + 4);
    offset += 4; // salt

    // Verify signature calculation
    final certBytes = utf8.encode(appCertificate);
    final kB1 = Hmac(sha256, issueTsBytes).convert(certBytes).bytes;
    final kB2 = Hmac(sha256, saltBytes).convert(kB1).bytes;
    final expectedSig = Hmac(sha256, kB2).convert(payload).bytes;

    expect(sig, expectedSig);
  });
}
