import 'package:flutter/material.dart';

import '../core_export.dart';

const double kScreenHorizontalPadding = 20;
const double kCardRadius = 18;
const double kControlButtonSize = 60;
const double kVideoHeaderHeight = 64;
const double kVideoPipWidth = 108;
const double kVideoPipHeight = 144;
const double kVideoPipMargin = 16;

final kRoomFieldDecoration = InputDecoration(
  filled: true,
  fillColor: AppColors.cardColor,
  hintStyle: const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    color: AppColors.secondaryTextLight,
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  prefixIcon: const Padding(
    padding: EdgeInsets.only(left: 16, right: 12),
    child: Icon(
      Icons.tag_rounded,
      size: 20,
      color: AppColors.secondaryTextLight,
    ),
  ),
  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.red1, width: 1),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.red1, width: 1),
  ),
  errorStyle: const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    color: AppColors.red1,
  ),
);
