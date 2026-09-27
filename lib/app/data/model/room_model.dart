class RoomModel {
  const RoomModel({
    this.roomId = '',
    this.channelName = '',
    this.localUid = 0,
    this.createdAt,
  });

  final String roomId;
  final String channelName;
  final int localUid;
  final DateTime? createdAt;

  String get displayRoomId => '#$roomId';

  RoomModel copyWith({
    String? roomId,
    String? channelName,
    int? localUid,
    DateTime? createdAt,
  }) {
    return RoomModel(
      roomId: roomId ?? this.roomId,
      channelName: channelName ?? this.channelName,
      localUid: localUid ?? this.localUid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
