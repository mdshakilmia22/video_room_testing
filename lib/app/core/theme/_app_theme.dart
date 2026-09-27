import 'package:flutter/material.dart';
import '_app_colors.dart';

abstract class AppTheme {
  static final _baseLight = ThemeData.light();

  static final TextTheme _textTheme = _baseLight.textTheme
      .apply(fontFamily: 'Poppins', bodyColor: AppColors.primaryTextLight)
      .copyWith(
        headlineLarge: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.primaryTextLight,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: AppColors.primaryTextLight,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextLight,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryTextLight,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryTextLight,
        ),
      );

  static ThemeData get lightTheme => _baseLight.copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBgLight,
    colorScheme: _baseLight.colorScheme.copyWith(primary: AppColors.primary),
    textTheme: _textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryContainerColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 60,
      titleTextStyle: _textTheme.titleMedium,
    ),

    dialogTheme: DialogThemeData(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    inputDecorationTheme: _inputDecorationTheme,

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(54),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
    ),
  );

  static InputDecorationTheme get _inputDecorationTheme {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AppColors.kOutlineColor,
        width: 1,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AppColors.red1,
        width: 1,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    );

    return InputDecorationTheme(
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      filled: true,
      fillColor: AppColors.primaryContainerColor,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        color: AppColors.secondaryTextLight,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: AppColors.red1,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

extension $ThemeDataColor on ThemeData {
  bool get _isDark => brightness == Brightness.dark;

  Color? get primaryTextColor {
    return _isDark ? null : AppColors.primaryTextLight;
  }

  Color? get secondaryTextColor {
    return _isDark ? null : AppColors.secondaryTextLight;
  }

  Color? get tertiaryTextColor {
    return _isDark ? null : AppColors.tertiaryTextLight;
  }

  Color? get unselectedColor {
    return _isDark ? null : AppColors.unselected;
  }

  Color? get secondaryBorderColor {
    return _isDark ? null : AppColors.border2;
  }
}
