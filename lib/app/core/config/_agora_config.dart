class AgoraConfig {
  AgoraConfig._();

  static const String appId = String.fromEnvironment(
    'AGORA_APP_ID',
    defaultValue: '68b249e23dc6458b9358bd0ba2237b5e',
  );

  static const String appCertificate = String.fromEnvironment(
    'AGORA_APP_CERTIFICATE',
    defaultValue: '802a873815d04b97a82add7946ac1bfc',
  );

  static const String tempToken = String.fromEnvironment(
    'AGORA_TEMP_TOKEN',
    defaultValue:
        '007eJxTYIj5tSoqSz0oLuf/rgCzrRp6acxN1csklojn3J505XHoK2cFBjOLJCMTy1Qj45RkMxNTiyRLYyCRYpCUaGRkbJ5kmmr+f0dWQyAjw/k/T1gZGSAQxOdkKEktLokvys/PZWAAAPC8IrE=',
  );

  static const bool useToken = bool.fromEnvironment(
    'AGORA_USE_TOKEN',
    defaultValue: true,
  );

  static const String channelPrefix = 'video_room';
}
