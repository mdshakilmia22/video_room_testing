enum RoomSetupMode { create, join }

class RoomSetupState {
  const RoomSetupState({
    this.roomId = '',
    this.channelName = '',
    this.joinRoomId = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final String roomId;
  final String channelName;
  final String joinRoomId;
  final bool isLoading;
  final String? errorMessage;

  String get displayRoomId => roomId.isEmpty ? '------' : roomId;

  RoomSetupState copyWith({
    String? roomId,
    String? channelName,
    String? joinRoomId,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RoomSetupState(
      roomId: roomId ?? this.roomId,
      channelName: channelName ?? this.channelName,
      joinRoomId: joinRoomId ?? this.joinRoomId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
