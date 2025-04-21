/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
/// Figma2Flutter
/// *****************************************************

library tokens;

import 'package:flutter/material.dart';

part 'tokens_extra.g.dart';

abstract class ITokens {
  ColorTokens get color;
  SpacingTokens get spacing;
  TextStyleTokens get textStyle;
  RadiiTokens get radii;
  ShadowTokens get shadow;
  MaterialColorTokens get materialColor;
}

abstract class ColorTokens {
  Color get vsdslColorPrimary;
  Color get vsdslColorPrimaryVariant;
  Color get vsdslColorOnPrimary;
  Color get vsdslColorSecondary;
  Color get vsdslColorSecondaryVariant;
  Color get vsdslColorOnSecondary;
  Color get vsdslColorTertiary;
  Color get vsdslColorTertiaryVariant;
  Color get vsdslColorOnTertiary;
  Color get vsdslColorNeutral;
  Color get vsdslColorNeutralInverse;
  Color get vsdslColorSurface100;
  Color get vsdslColorSurface200;
  Color get vsdslColorSurface300;
  Color get vsdslColorSurface400;
  Color get vsdslColorSurface500;
  Color get vsdslColorSurface600;
  Color get vsdslColorSurface700;
  Color get vsdslColorSurface800;
  Color get vsdslColorSurface900;
  Color get vsdslColorSurface1000;
  Color get vsdslColorOnSurface;
  Color get vsdslColorOnSurfaceInverse;
  Color get vsdslColorOnSurfaceVariant;
  Color get vsdslColorInfo;
  Color get vsdslColorSuccess;

  Color get vsdslColorSuccessVariant;
  Color get vsdslColorWarning;

  Color get vsdslColorOnWarningVariant;
  Color get vsdslColorError;

  Color get vsdslColorOnError;
  Color get vsdslColorDisabled;
  Color get vsdslColorOnDisabled;
  Color get vsdslColorLink;
  Color get vsdslColorOutline;
  Color get vsdslColorOutlineVariant;
  Color get vsdslColorOpacityPrimaryLg;
  Color get vsdslColorOpacityPrimaryXl;
  Color get vsdslColorOpacitySecondaryLg;
  Color get vsdslColorOpacitySecondaryXl;
  Color get vsdslColorOpacityNeutralXs;
  Color get vsdslColorOpacityNeutralSm;
  Color get vsdslColorOpacityNeutralMd;
  Color get vsdslColorOpacityNeutralLg;
  Color get vsdslColorOpacityNeutralXl;
}

abstract class SpacingTokens {
  EdgeInsets get vsdslSpacing2xs;
  EdgeInsets get vsdslSpacingXs;
  EdgeInsets get vsdslSpacingSm;
  EdgeInsets get vsdslSpacingMd;
  EdgeInsets get vsdslSpacingLg;
  EdgeInsets get vsdslSpacingXl;
  EdgeInsets get vsdslSpacing2xl;
  EdgeInsets get vsdslSpacing3xl;
  EdgeInsets get vsdslSpacing4xl;
  EdgeInsets get vsdslSpacing5xl;
}

abstract class TextStyleTokens {
  TextStyle get airsyncFontDisplay;
  TextStyle get airsyncFontTitle;
  TextStyle get airsyncFontNumber;
  TextStyle get airsyncFontDesc;
  TextStyle get airsyncFontInfo;
  TextStyle get airsyncFontSubtitle600;
  TextStyle get airsyncFontSubtitle400;
  TextStyle get airsyncFontUsername;
}

abstract class RadiiTokens {
  BorderRadius get vsdslRadiusXs;
  BorderRadius get vsdslRadiusSm;
  BorderRadius get vsdslRadiusmd;
  BorderRadius get vsdslRadiusLg;
  BorderRadius get vsdslRadiusXl;
  BorderRadius get vsdslRadius2xl;
  BorderRadius get vsdslRadiusFull;
}

abstract class ShadowTokens {
  List<BoxShadow> get vsdslShadowNeutralSm;
  List<BoxShadow> get vsdslShadowNeutralMd;
  List<BoxShadow> get vsdslShadowNeutralLg;
  List<BoxShadow> get vsdslShadowNeutralXl;
  List<BoxShadow> get vsdslShadowPrimarySm;
  List<BoxShadow> get vsdslShadowPrimaryMd;
  List<BoxShadow> get vsdslShadowPrimaryLg;
  List<BoxShadow> get vsdslShadowPrimaryXl;
  List<BoxShadow> get vsdslShadowSecondarySm;
  List<BoxShadow> get vsdslShadowSecondaryMd;
  List<BoxShadow> get vsdslShadowSecondaryLg;
  List<BoxShadow> get vsdslShadowSecondaryXl;
}

abstract class MaterialColorTokens {
  MaterialColor get vsdslColorSurface;
}

class DefaultTokens extends ITokens {
  @override
  ColorTokens get color => DefaultColorTokens();
  @override
  SpacingTokens get spacing => DefaultSpacingTokens();
  @override
  TextStyleTokens get textStyle => DefaultTextStyleTokens();
  @override
  RadiiTokens get radii => DefaultRadiiTokens();
  @override
  ShadowTokens get shadow => DefaultShadowTokens();
  @override
  MaterialColorTokens get materialColor => DefaultMaterialColorTokens();
}

class DefaultColorTokens extends ColorTokens {
  @override
  Color get vsdslColorPrimary => const Color(0xFF3C5AAA);
  @override
  Color get vsdslColorPrimaryVariant => const Color(0xFF2F3E6D);
  @override
  Color get vsdslColorOnPrimary => const Color(0xFFFFFFFF);
  @override
  Color get vsdslColorSecondary => const Color(0xFF5D80ED);
  @override
  Color get vsdslColorSecondaryVariant => const Color(0xFF4C71D2);
  @override
  Color get vsdslColorOnSecondary => const Color(0xFFFFFFFF);
  @override
  Color get vsdslColorTertiary => const Color(0xFF636D8A);
  @override
  Color get vsdslColorTertiaryVariant => const Color(0xFF3C455D);
  @override
  Color get vsdslColorOnTertiary => const Color(0xFFFFFFFF);
  @override
  Color get vsdslColorNeutral => const Color(0xFF000000);
  @override
  Color get vsdslColorNeutralInverse => const Color(0xFFFFFFFF);
  @override
  Color get vsdslColorSurface100 => const Color(0xFFFFFFFF);
  @override
  Color get vsdslColorSurface200 => const Color(0xFFE9EAF0);
  @override
  Color get vsdslColorSurface300 => const Color(0xFFD3D6E1);
  @override
  Color get vsdslColorSurface400 => const Color(0xFFC2C6D5);
  @override
  Color get vsdslColorSurface500 => const Color(0xFFA7ADC0);
  @override
  Color get vsdslColorSurface600 => const Color(0xFF838CA6);
  @override
  Color get vsdslColorSurface700 => const Color(0xFF636D8A);
  @override
  Color get vsdslColorSurface800 => const Color(0xFF3C455D);
  @override
  Color get vsdslColorSurface900 => const Color(0xFF20273E);
  @override
  Color get vsdslColorSurface1000 => const Color(0xFF151C32);
  @override
  Color get vsdslColorOnSurface => const Color(0xFF2A2A2A);
  @override
  Color get vsdslColorOnSurfaceInverse => const Color(0xFFFFFFFF);
  @override
  Color get vsdslColorOnSurfaceVariant => const Color(0xFF636D8A);
  @override
  Color get vsdslColorInfo => const Color(0xFF636D8A);
  @override
  Color get vsdslColorSuccess => const Color(0xFF3AC9CC);
  @override
  Color get vsdslColorSuccessVariant => const Color(0xFF2C9799);

  @override
  Color get vsdslColorWarning => const Color(0xFFEC6200);
  @override
  Color get vsdslColorOnWarningVariant => const Color(0xFFFFFFFF);

  @override
  Color get vsdslColorError => const Color(0xFFDB0025);

  @override
  Color get vsdslColorOnError => const Color(0xFFFFFFFF);
  @override
  Color get vsdslColorDisabled => const Color(0xFFEBEBEB);
  @override
  Color get vsdslColorOnDisabled => const Color(0xFFCFCFCF);
  @override
  Color get vsdslColorLink => const Color(0xFF3C5AAA);
  @override
  Color get vsdslColorOutline => const Color(0xFFE9EAF0);
  @override
  Color get vsdslColorOutlineVariant => const Color(0xFF3C455D);
  @override
  Color get vsdslColorOpacityPrimaryLg => const Color(0x7ADB0025);
  @override
  Color get vsdslColorOpacityPrimaryXl => const Color(0xA3DB0025);
  @override
  Color get vsdslColorOpacitySecondaryLg => const Color(0x7A3C5AAA);
  @override
  Color get vsdslColorOpacitySecondaryXl => const Color(0xA33C5AAA);
  @override
  Color get vsdslColorOpacityNeutralXs => const Color(0x29151C32);
  @override
  Color get vsdslColorOpacityNeutralSm => const Color(0x3D151C32);
  @override
  Color get vsdslColorOpacityNeutralMd => const Color(0x7A151C32);
  @override
  Color get vsdslColorOpacityNeutralLg => const Color(0xA3151C32);
  @override
  Color get vsdslColorOpacityNeutralXl => const Color(0xCC151C32);
}


class DefaultSpacingTokens extends SpacingTokens {
  @override
  EdgeInsets get vsdslSpacing2xs => const EdgeInsets.all(1.0);
  @override
  EdgeInsets get vsdslSpacingXs => const EdgeInsets.all(2.0);
  @override
  EdgeInsets get vsdslSpacingSm => const EdgeInsets.all(5.0);
  @override
  EdgeInsets get vsdslSpacingMd => const EdgeInsets.all(8.0);
  @override
  EdgeInsets get vsdslSpacingLg => const EdgeInsets.all(10.0);
  @override
  EdgeInsets get vsdslSpacingXl => const EdgeInsets.all(13.0);
  @override
  EdgeInsets get vsdslSpacing2xl => const EdgeInsets.all(16.0);
  @override
  EdgeInsets get vsdslSpacing3xl => const EdgeInsets.all(20.0);
  @override
  EdgeInsets get vsdslSpacing4xl => const EdgeInsets.all(29.0);
  @override
  EdgeInsets get vsdslSpacing5xl => const EdgeInsets.all(40.0);
}


class DefaultTextStyleTokens extends TextStyleTokens {
  @override
  TextStyle get airsyncFontDisplay => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 45.0,
  fontWeight: FontWeight.w700,
  height: 1.3,
  letterSpacing: 5.76,
);
  @override
  TextStyle get airsyncFontTitle => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 21.0,
  fontWeight: FontWeight.w500,
  height: 1.3,
  letterSpacing: -0.48,
);
  @override
  TextStyle get airsyncFontNumber => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 16.0,
  fontWeight: FontWeight.w700,
  height: 1.3,
  letterSpacing: 0.0,
);
  @override
  TextStyle get airsyncFontDesc => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 12.0,
  fontWeight: FontWeight.w400,
  height: 1.3,
  letterSpacing: 0.0,
);
  @override
  TextStyle get airsyncFontInfo => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 12.0,
  fontWeight: FontWeight.w400,
  height: 1.3,
  letterSpacing: 0.0,
);
  @override
  TextStyle get airsyncFontSubtitle600 => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 14.0,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 0.0,
);
  @override
  TextStyle get airsyncFontSubtitle400 => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 14.0,
  fontWeight: FontWeight.w400,
  height: 1.3,
  letterSpacing: 0.0,
);
  @override
  TextStyle get airsyncFontUsername => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 13.0,
  fontWeight: FontWeight.w600,
  height: 1.3,
  letterSpacing: 0.0,
);
}


class DefaultRadiiTokens extends RadiiTokens {
  @override
  BorderRadius get vsdslRadiusXs => BorderRadius.circular(2.0);
  @override
  BorderRadius get vsdslRadiusSm => BorderRadius.circular(5.0);
  @override
  BorderRadius get vsdslRadiusmd => BorderRadius.circular(8.0);
  @override
  BorderRadius get vsdslRadiusLg => BorderRadius.circular(10.0);
  @override
  BorderRadius get vsdslRadiusXl => BorderRadius.circular(20.0);
  @override
  BorderRadius get vsdslRadius2xl => BorderRadius.circular(40.0);
  @override
  BorderRadius get vsdslRadiusFull => BorderRadius.circular(9999.0);
}


class DefaultShadowTokens extends ShadowTokens {
  @override
  List<BoxShadow> get vsdslShadowNeutralSm => const [
  BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
    spreadRadius: 0.0,
    color: Color(0x29151C32),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowNeutralMd => const [
  BoxShadow(
    offset: Offset(0.0, 4.0),
    blurRadius: 8.0,
    spreadRadius: 0.0,
    color: Color(0x29151C32),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowNeutralLg => const [
  BoxShadow(
    offset: Offset(0.0, 8.0),
    blurRadius: 16.0,
    spreadRadius: 0.0,
    color: Color(0x3D151C32),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowNeutralXl => const [
  BoxShadow(
    offset: Offset(0.0, 16.0),
    blurRadius: 24.0,
    spreadRadius: 0.0,
    color: Color(0x3D151C32),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowPrimarySm => const [
  BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
    spreadRadius: 0.0,
    color: Color(0x7ADB0025),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowPrimaryMd => const [
  BoxShadow(
    offset: Offset(0.0, 4.0),
    blurRadius: 8.0,
    spreadRadius: 0.0,
    color: Color(0x7ADB0025),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowPrimaryLg => const [
  BoxShadow(
    offset: Offset(0.0, 8.0),
    blurRadius: 16.0,
    spreadRadius: 0.0,
    color: Color(0x7ADB0025),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowPrimaryXl => const [
  BoxShadow(
    offset: Offset(0.0, 16.0),
    blurRadius: 24.0,
    spreadRadius: 0.0,
    color: Color(0x7ADB0025),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowSecondarySm => const [
  BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
    spreadRadius: 0.0,
    color: Color(0x7A3C5AAA),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowSecondaryMd => const [
  BoxShadow(
    offset: Offset(0.0, 4.0),
    blurRadius: 8.0,
    spreadRadius: 0.0,
    color: Color(0x7A3C5AAA),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowSecondaryLg => const [
  BoxShadow(
    offset: Offset(0.0, 8.0),
    blurRadius: 16.0,
    spreadRadius: 0.0,
    color: Color(0x7A3C5AAA),
  ),
];
  @override
  List<BoxShadow> get vsdslShadowSecondaryXl => const [
  BoxShadow(
    offset: Offset(0.0, 16.0),
    blurRadius: 24.0,
    spreadRadius: 0.0,
    color: Color(0xA33C5AAA),
  ),
];
}


class DefaultMaterialColorTokens extends MaterialColorTokens {
  @override
MaterialColor get vsdslColorSurface => const MaterialColor(0xFFA7ADC0, {
  100: Color(0xFFFFFFFF),
  200: Color(0xFFE9EAF0),
  300: Color(0xFFD3D6E1),
  400: Color(0xFFC2C6D5),
  500: Color(0xFFA7ADC0),
  600: Color(0xFF838CA6),
  700: Color(0xFF636D8A),
  800: Color(0xFF3C455D),
  900: Color(0xFF20273E),
});

}
