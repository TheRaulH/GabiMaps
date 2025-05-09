import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff004e9f),
      surfaceTint: Color(0xff005cba),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff0066cc),
      onPrimaryContainer: Color(0xffdfe8ff),
      secondary: Color(0xff004e9f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff0066cc),
      onSecondaryContainer: Color(0xffdfe8ff),
      tertiary: Color(0xff003875),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff004e9f),
      onTertiaryContainer: Color(0xffa3c3ff),
      error: Color(0xffbc0100),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffeb0000),
      onErrorContainer: Color(0xfffffbff),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff414753),
      outline: Color(0xff727784),
      outlineVariant: Color(0xffc1c6d5),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xffd7e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00458e),
      secondaryFixed: Color(0xffd7e3ff),
      onSecondaryFixed: Color(0xff001b3e),
      secondaryFixedDim: Color(0xffaac7ff),
      onSecondaryFixedVariant: Color(0xff00458e),
      tertiaryFixed: Color(0xffd7e3ff),
      onTertiaryFixed: Color(0xff001b3e),
      tertiaryFixedDim: Color(0xffaac7ff),
      onTertiaryFixedVariant: Color(0xff00458e),
      surfaceDim: Color(0xffddd9d9),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e7),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00356f),
      surfaceTint: Color(0xff005cba),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff0066cc),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff00356f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff0066cc),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff003570),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff004e9f),
      onTertiaryContainer: Color(0xffeaefff),
      error: Color(0xff740100),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffdc0100),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff313642),
      outline: Color(0xff4d525f),
      outlineVariant: Color(0xff686d7a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff126bd1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff0053a8),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff126bd1),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff0053a8),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff356cbf),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff0e53a4),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xffebe7e7),
      surfaceContainerHigh: Color(0xffdfdcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002b5d),
      surfaceTint: Color(0xff005cba),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004893),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff002b5d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff004893),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002b5d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff004793),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600000),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff980100),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff272c37),
      outlineVariant: Color(0xff444955),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffaac7ff),
      primaryFixed: Color(0xff004893),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003169),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff004893),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003169),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff004793),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003169),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffaac7ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff002f65),
      primaryContainer: Color(0xff0066cc),
      onPrimaryContainer: Color(0xffdfe8ff),
      secondary: Color(0xffaac7ff),
      onSecondary: Color(0xff002f65),
      secondaryContainer: Color(0xff0066cc),
      onSecondaryContainer: Color(0xffdfe8ff),
      tertiary: Color(0xffaac7ff),
      onTertiary: Color(0xff002f65),
      tertiaryContainer: Color(0xff004e9f),
      onTertiaryContainer: Color(0xffa3c3ff),
      error: Color(0xffffb4a8),
      onError: Color(0xff690100),
      errorContainer: Color(0xffff5540),
      onErrorContainer: Color(0xff360000),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc1c6d5),
      outline: Color(0xff8b919e),
      outlineVariant: Color(0xff414753),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff005cba),
      primaryFixed: Color(0xffd7e3ff),
      onPrimaryFixed: Color(0xff001b3e),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00458e),
      secondaryFixed: Color(0xffd7e3ff),
      onSecondaryFixed: Color(0xff001b3e),
      secondaryFixedDim: Color(0xffaac7ff),
      onSecondaryFixedVariant: Color(0xff00458e),
      tertiaryFixed: Color(0xffd7e3ff),
      onTertiaryFixed: Color(0xff001b3e),
      tertiaryFixedDim: Color(0xffaac7ff),
      onTertiaryFixedVariant: Color(0xff00458e),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcdddff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff002551),
      primaryContainer: Color(0xff4a90f8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffcdddff),
      onSecondary: Color(0xff002551),
      secondaryContainer: Color(0xff4a90f8),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffcdddff),
      onTertiary: Color(0xff002551),
      tertiaryContainer: Color(0xff5d91e5),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cb),
      onError: Color(0xff540000),
      errorContainer: Color(0xffff5540),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd7dceb),
      outline: Color(0xffadb2c0),
      outlineVariant: Color(0xff8b909e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff004690),
      primaryFixed: Color(0xffd7e3ff),
      onPrimaryFixed: Color(0xff00112b),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00356f),
      secondaryFixed: Color(0xffd7e3ff),
      onSecondaryFixed: Color(0xff00112b),
      secondaryFixedDim: Color(0xffaac7ff),
      onSecondaryFixedVariant: Color(0xff00356f),
      tertiaryFixed: Color(0xffd7e3ff),
      onTertiaryFixed: Color(0xff00112b),
      tertiaryFixedDim: Color(0xffaac7ff),
      onTertiaryFixedVariant: Color(0xff003570),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffebf0ff),
      surfaceTint: Color(0xffaac7ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa4c3ff),
      onPrimaryContainer: Color(0xff000b20),
      secondary: Color(0xffebf0ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffa4c3ff),
      onSecondaryContainer: Color(0xff000b20),
      tertiary: Color(0xffebf0ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa4c3ff),
      onTertiaryContainer: Color(0xff000b20),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea1),
      onErrorContainer: Color(0xff220000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffebf0ff),
      outlineVariant: Color(0xffbec2d1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff004690),
      primaryFixed: Color(0xffd7e3ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffaac7ff),
      onPrimaryFixedVariant: Color(0xff00112b),
      secondaryFixed: Color(0xffd7e3ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffaac7ff),
      onSecondaryFixedVariant: Color(0xff00112b),
      tertiaryFixed: Color(0xffd7e3ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffaac7ff),
      onTertiaryFixedVariant: Color(0xff00112b),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff474646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  /// Custom Color 1
  static const customColor1 = ExtendedColor(
    seed: Color(0xff000e26),
    value: Color(0xff000e26),
    light: ColorFamily(
      color: Color(0xff000000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff0c1b34),
      onColorContainer: Color(0xff7684a1),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff000000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff0c1b34),
      onColorContainer: Color(0xff7684a1),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff000000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff0c1b34),
      onColorContainer: Color(0xff7684a1),
    ),
    dark: ColorFamily(
      color: Color(0xffb8c7e7),
      onColor: Color(0xff22314a),
      colorContainer: Color(0xff000e26),
      onColorContainer: Color(0xff6d7c99),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffb8c7e7),
      onColor: Color(0xff22314a),
      colorContainer: Color(0xff000e26),
      onColorContainer: Color(0xff6d7c99),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffb8c7e7),
      onColor: Color(0xff22314a),
      colorContainer: Color(0xff000e26),
      onColorContainer: Color(0xff6d7c99),
    ),
  );

  /// Custom Color 2
  static const customColor2 = ExtendedColor(
    seed: Color(0xffff0000),
    value: Color(0xffff0000),
    light: ColorFamily(
      color: Color(0xffbc0100),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffeb0000),
      onColorContainer: Color(0xfffffbff),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xffbc0100),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffeb0000),
      onColorContainer: Color(0xfffffbff),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xffbc0100),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffeb0000),
      onColorContainer: Color(0xfffffbff),
    ),
    dark: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690100),
      colorContainer: Color(0xffff5540),
      onColorContainer: Color(0xff360000),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690100),
      colorContainer: Color(0xffff5540),
      onColorContainer: Color(0xff360000),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690100),
      colorContainer: Color(0xffff5540),
      onColorContainer: Color(0xff360000),
    ),
  );

  /// Custom Color 5
  static const customColor5 = ExtendedColor(
    seed: Color(0xff001a33),
    value: Color(0xff001a33),
    light: ColorFamily(
      color: Color(0xff000000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff021c36),
      onColorContainer: Color(0xff6f85a3),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff000000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff021c36),
      onColorContainer: Color(0xff6f85a3),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff000000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff021c36),
      onColorContainer: Color(0xff6f85a3),
    ),
    dark: ColorFamily(
      color: Color(0xffb1c8e9),
      onColor: Color(0xff1a324c),
      colorContainer: Color(0xff001a33),
      onColorContainer: Color(0xff6d84a2),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffb1c8e9),
      onColor: Color(0xff1a324c),
      colorContainer: Color(0xff001a33),
      onColorContainer: Color(0xff6d84a2),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffb1c8e9),
      onColor: Color(0xff1a324c),
      colorContainer: Color(0xff001a33),
      onColorContainer: Color(0xff6d84a2),
    ),
  );

  /// Custom Color 6
  static const customColor6 = ExtendedColor(
    seed: Color(0xff003366),
    value: Color(0xff003366),
    light: ColorFamily(
      color: Color(0xff001e40),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff003366),
      onColorContainer: Color(0xff799dd6),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff001e40),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff003366),
      onColorContainer: Color(0xff799dd6),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff001e40),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff003366),
      onColorContainer: Color(0xff799dd6),
    ),
    dark: ColorFamily(
      color: Color(0xffa7c8ff),
      onColor: Color(0xff003061),
      colorContainer: Color(0xff003366),
      onColorContainer: Color(0xff799dd6),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa7c8ff),
      onColor: Color(0xff003061),
      colorContainer: Color(0xff003366),
      onColorContainer: Color(0xff799dd6),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa7c8ff),
      onColor: Color(0xff003061),
      colorContainer: Color(0xff003366),
      onColorContainer: Color(0xff799dd6),
    ),
  );

  /// Custom Color 7
  static const customColor7 = ExtendedColor(
    seed: Color(0xff004c99),
    value: Color(0xff004c99),
    light: ColorFamily(
      color: Color(0xff00366f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff004c99),
      onColorContainer: Color(0xff9dbfff),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff00366f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff004c99),
      onColorContainer: Color(0xff9dbfff),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff00366f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff004c99),
      onColorContainer: Color(0xff9dbfff),
    ),
    dark: ColorFamily(
      color: Color(0xffaac7ff),
      onColor: Color(0xff002f64),
      colorContainer: Color(0xff004c99),
      onColorContainer: Color(0xff9dbfff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffaac7ff),
      onColor: Color(0xff002f64),
      colorContainer: Color(0xff004c99),
      onColorContainer: Color(0xff9dbfff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffaac7ff),
      onColor: Color(0xff002f64),
      colorContainer: Color(0xff004c99),
      onColorContainer: Color(0xff9dbfff),
    ),
  );

  /// Custom Color 8
  static const customColor8 = ExtendedColor(
    seed: Color(0xff0066cc),
    value: Color(0xff0066cc),
    light: ColorFamily(
      color: Color(0xff004e9f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff0066cc),
      onColorContainer: Color(0xffdfe8ff),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff004e9f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff0066cc),
      onColorContainer: Color(0xffdfe8ff),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff004e9f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff0066cc),
      onColorContainer: Color(0xffdfe8ff),
    ),
    dark: ColorFamily(
      color: Color(0xffaac7ff),
      onColor: Color(0xff002f65),
      colorContainer: Color(0xff0066cc),
      onColorContainer: Color(0xffdfe8ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffaac7ff),
      onColor: Color(0xff002f65),
      colorContainer: Color(0xff0066cc),
      onColorContainer: Color(0xffdfe8ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffaac7ff),
      onColor: Color(0xff002f65),
      colorContainer: Color(0xff0066cc),
      onColorContainer: Color(0xffdfe8ff),
    ),
  );

  /// Custom Color 9
  static const customColor9 = ExtendedColor(
    seed: Color(0xff3399ff),
    value: Color(0xff3399ff),
    light: ColorFamily(
      color: Color(0xff0060ab),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff3399ff),
      onColorContainer: Color(0xff00305a),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff0060ab),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff3399ff),
      onColorContainer: Color(0xff00305a),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff0060ab),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff3399ff),
      onColorContainer: Color(0xff00305a),
    ),
    dark: ColorFamily(
      color: Color(0xffa3c9ff),
      onColor: Color(0xff00315c),
      colorContainer: Color(0xff3399ff),
      onColorContainer: Color(0xff00305a),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa3c9ff),
      onColor: Color(0xff00315c),
      colorContainer: Color(0xff3399ff),
      onColorContainer: Color(0xff00305a),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa3c9ff),
      onColor: Color(0xff00315c),
      colorContainer: Color(0xff3399ff),
      onColorContainer: Color(0xff00305a),
    ),
  );

  /// Custom Color 10
  static const customColor10 = ExtendedColor(
    seed: Color(0xff660000),
    value: Color(0xff660000),
    light: ColorFamily(
      color: Color(0xff3e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff660000),
      onColorContainer: Color(0xfff56b58),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff3e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff660000),
      onColorContainer: Color(0xfff56b58),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff3e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff660000),
      onColorContainer: Color(0xfff56b58),
    ),
    dark: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff680201),
      colorContainer: Color(0xff660000),
      onColorContainer: Color(0xfff56b58),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff680201),
      colorContainer: Color(0xff660000),
      onColorContainer: Color(0xfff56b58),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff680201),
      colorContainer: Color(0xff660000),
      onColorContainer: Color(0xfff56b58),
    ),
  );

  /// Custom Color 11
  static const customColor11 = ExtendedColor(
    seed: Color(0xff990000),
    value: Color(0xff990000),
    light: ColorFamily(
      color: Color(0xff6e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff990000),
      onColorContainer: Color(0xffffa092),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff6e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff990000),
      onColorContainer: Color(0xffffa092),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff6e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff990000),
      onColorContainer: Color(0xffffa092),
    ),
    dark: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690000),
      colorContainer: Color(0xff990000),
      onColorContainer: Color(0xffffa092),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690000),
      colorContainer: Color(0xff990000),
      onColorContainer: Color(0xffffa092),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690000),
      colorContainer: Color(0xff990000),
      onColorContainer: Color(0xffffa092),
    ),
  );

  /// Custom Color 12
  static const customColor12 = ExtendedColor(
    seed: Color(0xffcc0000),
    value: Color(0xffcc0000),
    light: ColorFamily(
      color: Color(0xff9e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcc0000),
      onColorContainer: Color(0xffffdad4),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff9e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcc0000),
      onColorContainer: Color(0xffffdad4),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff9e0000),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffcc0000),
      onColorContainer: Color(0xffffdad4),
    ),
    dark: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690000),
      colorContainer: Color(0xffcc0000),
      onColorContainer: Color(0xffffdad4),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690000),
      colorContainer: Color(0xffcc0000),
      onColorContainer: Color(0xffffdad4),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb4a8),
      onColor: Color(0xff690000),
      colorContainer: Color(0xffcc0000),
      onColorContainer: Color(0xffffdad4),
    ),
  );

  /// Custom Color 13
  static const customColor13 = ExtendedColor(
    seed: Color(0xffff3333),
    value: Color(0xffff3333),
    light: ColorFamily(
      color: Color(0xffbb0014),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe51c24),
      onColorContainer: Color(0xfffffbff),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xffbb0014),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe51c24),
      onColorContainer: Color(0xfffffbff),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xffbb0014),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe51c24),
      onColorContainer: Color(0xfffffbff),
    ),
    dark: ColorFamily(
      color: Color(0xffffb4ac),
      onColor: Color(0xff690006),
      colorContainer: Color(0xffff544c),
      onColorContainer: Color(0xff470003),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb4ac),
      onColor: Color(0xff690006),
      colorContainer: Color(0xffff544c),
      onColorContainer: Color(0xff470003),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb4ac),
      onColor: Color(0xff690006),
      colorContainer: Color(0xffff544c),
      onColorContainer: Color(0xff470003),
    ),
  );

  /// Custom Color 14
  static const customColor14 = ExtendedColor(
    seed: Color(0xff212121),
    value: Color(0xff212121),
    light: ColorFamily(
      color: Color(0xff0a0a0a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff212121),
      onColorContainer: Color(0xff898888),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff0a0a0a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff212121),
      onColorContainer: Color(0xff898888),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff0a0a0a),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff212121),
      onColorContainer: Color(0xff898888),
    ),
    dark: ColorFamily(
      color: Color(0xffc8c6c5),
      onColor: Color(0xff303030),
      colorContainer: Color(0xff212121),
      onColorContainer: Color(0xff898888),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffc8c6c5),
      onColor: Color(0xff303030),
      colorContainer: Color(0xff212121),
      onColorContainer: Color(0xff898888),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffc8c6c5),
      onColor: Color(0xff303030),
      colorContainer: Color(0xff212121),
      onColorContainer: Color(0xff898888),
    ),
  );

  /// Custom Color 4
  static const customColor4 = ExtendedColor(
    seed: Color(0xff424242),
    value: Color(0xff424242),
    light: ColorFamily(
      color: Color(0xff2c2c2c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff424242),
      onColorContainer: Color(0xffb0aeae),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff2c2c2c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff424242),
      onColorContainer: Color(0xffb0aeae),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff2c2c2c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff424242),
      onColorContainer: Color(0xffb0aeae),
    ),
    dark: ColorFamily(
      color: Color(0xffc8c6c6),
      onColor: Color(0xff303030),
      colorContainer: Color(0xff424242),
      onColorContainer: Color(0xffb0aeae),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffc8c6c6),
      onColor: Color(0xff303030),
      colorContainer: Color(0xff424242),
      onColorContainer: Color(0xffb0aeae),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffc8c6c6),
      onColor: Color(0xff303030),
      colorContainer: Color(0xff424242),
      onColorContainer: Color(0xffb0aeae),
    ),
  );

  /// Custom Color 15
  static const customColor15 = ExtendedColor(
    seed: Color(0xff616161),
    value: Color(0xff616161),
    light: ColorFamily(
      color: Color(0xff494949),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff616161),
      onColorContainer: Color(0xffdedcdc),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff494949),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff616161),
      onColorContainer: Color(0xffdedcdc),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff494949),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff616161),
      onColorContainer: Color(0xffdedcdc),
    ),
    dark: ColorFamily(
      color: Color(0xffc7c6c6),
      onColor: Color(0xff303031),
      colorContainer: Color(0xff616161),
      onColorContainer: Color(0xffdedcdc),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffc7c6c6),
      onColor: Color(0xff303031),
      colorContainer: Color(0xff616161),
      onColorContainer: Color(0xffdedcdc),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffc7c6c6),
      onColor: Color(0xff303031),
      colorContainer: Color(0xff616161),
      onColorContainer: Color(0xffdedcdc),
    ),
  );

  /// Custom Color 16
  static const customColor16 = ExtendedColor(
    seed: Color(0xff9e9e9e),
    value: Color(0xff9e9e9e),
    light: ColorFamily(
      color: Color(0xff5e5e5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff9e9e9e),
      onColorContainer: Color(0xff343636),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff5e5e5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff9e9e9e),
      onColorContainer: Color(0xff343636),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff5e5e5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff9e9e9e),
      onColorContainer: Color(0xff343636),
    ),
    dark: ColorFamily(
      color: Color(0xffc7c6c6),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xff9e9e9e),
      onColorContainer: Color(0xff343636),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffc7c6c6),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xff9e9e9e),
      onColorContainer: Color(0xff343636),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffc7c6c6),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xff9e9e9e),
      onColorContainer: Color(0xff343636),
    ),
  );

  /// Custom Color 17
  static const customColor17 = ExtendedColor(
    seed: Color(0xffe0e0e0),
    value: Color(0xffe0e0e0),
    light: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe0e0e0),
      onColorContainer: Color(0xff626363),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe0e0e0),
      onColorContainer: Color(0xff626363),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe0e0e0),
      onColorContainer: Color(0xff626363),
    ),
    dark: ColorFamily(
      color: Color(0xfffdfdfc),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe0e0e0),
      onColorContainer: Color(0xff626363),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xfffdfdfc),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe0e0e0),
      onColorContainer: Color(0xff626363),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xfffdfdfc),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe0e0e0),
      onColorContainer: Color(0xff626363),
    ),
  );

  /// Custom Color 18
  static const customColor18 = ExtendedColor(
    seed: Color(0xffeeeeee),
    value: Color(0xffeeeeee),
    light: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffeeeeee),
      onColorContainer: Color(0xff6a6c6c),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffeeeeee),
      onColorContainer: Color(0xff6a6c6c),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffeeeeee),
      onColorContainer: Color(0xff6a6c6c),
    ),
    dark: ColorFamily(
      color: Color(0xffffffff),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe2e2e2),
      onColorContainer: Color(0xff636565),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffffff),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe2e2e2),
      onColorContainer: Color(0xff636565),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffffff),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe2e2e2),
      onColorContainer: Color(0xff636565),
    ),
  );

  /// Custom Color 3
  static const customColor3 = ExtendedColor(
    seed: Color(0xffffffff),
    value: Color(0xffffffff),
    light: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffffff),
      onColorContainer: Color(0xff747676),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffffff),
      onColorContainer: Color(0xff747676),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff5d5f5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffffff),
      onColorContainer: Color(0xff747676),
    ),
    dark: ColorFamily(
      color: Color(0xffffffff),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe2e2e2),
      onColorContainer: Color(0xff636565),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffffff),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe2e2e2),
      onColorContainer: Color(0xff636565),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffffff),
      onColor: Color(0xff2f3131),
      colorContainer: Color(0xffe2e2e2),
      onColorContainer: Color(0xff636565),
    ),
  );

  List<ExtendedColor> get extendedColors => [
    customColor1,
    customColor2,
    customColor5,
    customColor6,
    customColor7,
    customColor8,
    customColor9,
    customColor10,
    customColor11,
    customColor12,
    customColor13,
    customColor14,
    customColor4,
    customColor15,
    customColor16,
    customColor17,
    customColor18,
    customColor3,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
