import 'package:flutter/material.dart';
import 'package:agora_video_call_test/app/core/core_export.dart';

class RoomInputField extends StatelessWidget {
  const RoomInputField({
    required this.controller,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLength: 8,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.primaryTextLight,
      ),
      decoration: kRoomFieldDecoration.copyWith(
        hintText: 'Enter Room ID',
        errorText: errorText,
        counterText: '',
      ),
    );
  }
}
