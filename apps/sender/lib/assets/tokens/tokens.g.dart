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
  Color get vsdswColorPrimary;
  Color get vsdswColorPrimaryVariant;
  Color get vsdswColorOnPrimary;
  Color get vsdswColorSecondary;
  Color get vsdswColorSecondaryVariant;
  Color get vsdswColorOnSecondary;
  Color get vsdswColorTertiary;
  Color get vsdswColorTertiaryVariant;
  Color get vsdswColorOnTertiary;
  Color get vsdswColorNeutral;
  Color get vsdswColorNeutralInverse;
  Color get vsdswColorSurface100;
  Color get vsdswColorSurface200;
  Color get vsdswColorSurface300;
  Color get vsdswColorSurface400;
  Color get vsdswColorSurface500;
  Color get vsdswColorSurface600;
  Color get vsdswColorSurface700;
  Color get vsdswColorSurface800;
  Color get vsdswColorSurface900;
  Color get vsdswColorSurface1000;
  Color get vsdswColorSurface100Variant;
  Color get vsdswColorSurface200Variant;
  Color get vsdswColorSurfaceInverse;
  Color get vsdswColorOnSurface;
  Color get vsdswColorOnSurfaceInverse;
  Color get vsdswColorOnSurfaceVariant;
  Color get vsdswColorInfo;
  Color get vsdswColorInfoVariant;
  Color get vsdswColorOnInfo;
  Color get vsdswColorSuccess;
  Color get vsdswColorSuccessVariant;
  Color get vsdswColorOnSuccess;
  Color get vsdswColorWarning;
  Color get vsdswColorOnWarning;
  Color get vsdswColorError;
  Color get vsdswColorOnError;
  Color get vsdswColorDisabled;
  Color get vsdswColorOnDisabled;
  Color get vsdswColorLink;
  Color get vsdswColorOutline;
  Color get vsdswColorOutlineVariant;
  Color get vsdswColorOpacityPrimarySm;
  Color get vsdswColorOpacityPrimaryMd;
  Color get vsdswColorOpacityPrimaryLg;
  Color get vsdswColorOpacityPrimaryXl;
  Color get vsdswColorOpacitySecondarySm;
  Color get vsdswColorOpacitySecondarymd;
  Color get vsdswColorOpacitySecondaryLg;
  Color get vsdswColorOpacitySecondaryXl;
  Color get vsdswColorOpacityNeutralSm;
  Color get vsdswColorOpacityNeutralMd;
  Color get vsdswColorOpacityNeutralLg;
  Color get vsdswColorOpacityNeutralXl;
}

abstract class SpacingTokens {
  EdgeInsets get vsdswSpacing2xs;
  EdgeInsets get vsdswSpacingXs;
  EdgeInsets get vsdswSpacingSm;
  EdgeInsets get vsdswSpacingMd;
  EdgeInsets get vsdswSpacingLg;
  EdgeInsets get vsdswSpacingXl;
  EdgeInsets get vsdswSpacing2xl;
  EdgeInsets get vsdswSpacing3xl;
  EdgeInsets get vsdswSpacing4xl;
  EdgeInsets get vsdswSpacing5xl;
}

abstract class TextStyleTokens {
  TextStyle get vsdswDisplaySm;
  TextStyle get vsdswHeadingLg;
  TextStyle get vsdswHeadingMd;
  TextStyle get vsdswTitleMd;
  TextStyle get vsdswBodyLg;
  TextStyle get vsdswBodyMd;
  TextStyle get vsdswBodySm;
  TextStyle get vsdswLabelMd;
  TextStyle get vsdswLabelSm;
  TextStyle get vsdswLabelXs;
}

abstract class RadiiTokens {
  BorderRadius get vsdswRadiusSm;
  BorderRadius get vsdswRadiusmd;
  BorderRadius get vsdswRadiusLg;
  BorderRadius get vsdswRadiusXl;
  BorderRadius get vsdswRadius2xl;
  BorderRadius get vsdswRadius3xl;
  BorderRadius get vsdswRadiusFull;
}

abstract class ShadowTokens {
  List<BoxShadow> get vsdswShadowNeutralSm;
  List<BoxShadow> get vsdswShadowNeutralMd;
  List<BoxShadow> get vsdswShadowNeutralLg;
  List<BoxShadow> get vsdswShadowNeutralXl;
  List<BoxShadow> get vsdswShadowPrimarySm;
  List<BoxShadow> get vsdswShadowPrimaryMd;
  List<BoxShadow> get vsdswShadowPrimaryLg;
  List<BoxShadow> get vsdswShadowPrimaryXl;
  List<BoxShadow> get vsdswShadowSecondarySm;
  List<BoxShadow> get vsdswShadowSecondaryMd;
  List<BoxShadow> get vsdswShadowSecondaryLg;
  List<BoxShadow> get vsdswShadowSecondaryXl;
}

abstract class MaterialColorTokens {
  MaterialColor get vsdswColorSurface;
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
  Color get vsdswColorPrimary => const Color(0xFF3C5AAA);
  @override
  Color get vsdswColorPrimaryVariant => const Color(0xFF2F3E6D);
  @override
  Color get vsdswColorOnPrimary => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorSecondary => const Color(0xFF5D80ED);
  @override
  Color get vsdswColorSecondaryVariant => const Color(0xFF4C71D2);
  @override
  Color get vsdswColorOnSecondary => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorTertiary => const Color(0xFF636D8A);
  @override
  Color get vsdswColorTertiaryVariant => const Color(0xFF3C455D);
  @override
  Color get vsdswColorOnTertiary => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorNeutral => const Color(0xFF000000);
  @override
  Color get vsdswColorNeutralInverse => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorSurface100 => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorSurface200 => const Color(0xFFE9EAF0);
  @override
  Color get vsdswColorSurface300 => const Color(0xFFD3D6E1);
  @override
  Color get vsdswColorSurface400 => const Color(0xFFC2C6D5);
  @override
  Color get vsdswColorSurface500 => const Color(0xFFA7ADC0);
  @override
  Color get vsdswColorSurface600 => const Color(0xFF838CA6);
  @override
  Color get vsdswColorSurface700 => const Color(0xFF636D8A);
  @override
  Color get vsdswColorSurface800 => const Color(0xFF3C455D);
  @override
  Color get vsdswColorSurface900 => const Color(0xFF20273E);
  @override
  Color get vsdswColorSurface1000 => const Color(0xFF151C32);
  @override
  Color get vsdswColorSurface100Variant => const Color(0xFFE5ECFF);
  @override
  Color get vsdswColorSurface200Variant => const Color(0xFFBCCEFE);
  @override
  Color get vsdswColorSurfaceInverse => const Color(0xFF151C32);
  @override
  Color get vsdswColorOnSurface => const Color(0xFF2A2A2A);
  @override
  Color get vsdswColorOnSurfaceInverse => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorOnSurfaceVariant => const Color(0xFF636D8A);
  @override
  Color get vsdswColorInfo => const Color(0xFF636D8A);
  @override
  Color get vsdswColorInfoVariant => const Color(0xFF3C455D);
  @override
  Color get vsdswColorOnInfo => const Color(0xFF333333);
  @override
  Color get vsdswColorSuccess => const Color(0xFF3AC9CC);
  @override
  Color get vsdswColorSuccessVariant => const Color(0xFF2C9799);
  @override
  Color get vsdswColorOnSuccess => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorWarning => const Color(0xFFEC6200);
  @override
  Color get vsdswColorOnWarning => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorError => const Color(0xFFDB0025);
  @override
  Color get vsdswColorOnError => const Color(0xFFFFFFFF);
  @override
  Color get vsdswColorDisabled => const Color(0xFFEBEBEB);
  @override
  Color get vsdswColorOnDisabled => const Color(0xFFB2B2B2);
  @override
  Color get vsdswColorLink => const Color(0xFF3C5AAA);
  @override
  Color get vsdswColorOutline => const Color(0xFFD3D6E1);
  @override
  Color get vsdswColorOutlineVariant => const Color(0xFF3C455D);
  @override
  Color get vsdswColorOpacityPrimarySm => const Color(0x143C5AAA);
  @override
  Color get vsdswColorOpacityPrimaryMd => const Color(0x293C5AAA);
  @override
  Color get vsdswColorOpacityPrimaryLg => const Color(0x7A3C5AAA);
  @override
  Color get vsdswColorOpacityPrimaryXl => const Color(0xA33C5AAA);
  @override
  Color get vsdswColorOpacitySecondarySm => const Color(0x145D80ED);
  @override
  Color get vsdswColorOpacitySecondarymd => const Color(0x295D80ED);
  @override
  Color get vsdswColorOpacitySecondaryLg => const Color(0x7A5D80ED);
  @override
  Color get vsdswColorOpacitySecondaryXl => const Color(0xA35D80ED);
  @override
  Color get vsdswColorOpacityNeutralSm => const Color(0x29151C32);
  @override
  Color get vsdswColorOpacityNeutralMd => const Color(0x52151C32);
  @override
  Color get vsdswColorOpacityNeutralLg => const Color(0xA3151C32);
  @override
  Color get vsdswColorOpacityNeutralXl => const Color(0xCC151C32);
}


class DefaultSpacingTokens extends SpacingTokens {
  @override
  EdgeInsets get vsdswSpacing2xs => const EdgeInsets.all(4.0);
  @override
  EdgeInsets get vsdswSpacingXs => const EdgeInsets.all(8.0);
  @override
  EdgeInsets get vsdswSpacingSm => const EdgeInsets.all(12.0);
  @override
  EdgeInsets get vsdswSpacingMd => const EdgeInsets.all(16.0);
  @override
  EdgeInsets get vsdswSpacingLg => const EdgeInsets.all(24.0);
  @override
  EdgeInsets get vsdswSpacingXl => const EdgeInsets.all(32.0);
  @override
  EdgeInsets get vsdswSpacing2xl => const EdgeInsets.all(40.0);
  @override
  EdgeInsets get vsdswSpacing3xl => const EdgeInsets.all(48.0);
  @override
  EdgeInsets get vsdswSpacing4xl => const EdgeInsets.all(56.0);
  @override
  EdgeInsets get vsdswSpacing5xl => const EdgeInsets.all(64.0);
}


class DefaultTextStyleTokens extends TextStyleTokens {
  @override
  TextStyle get vsdswDisplaySm => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 48.0,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: -0.16,
);
  @override
  TextStyle get vsdswHeadingLg => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 32.0,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: -0.16,
);
  @override
  TextStyle get vsdswHeadingMd => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 24.0,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: -0.16,
);
  @override
  TextStyle get vsdswTitleMd => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 20.0,
  fontWeight: FontWeight.w700,
  height: 1.4,
  letterSpacing: -0.16,
);
  @override
  TextStyle get vsdswBodyLg => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 18.0,
  fontWeight: FontWeight.w400,
  height: 1.4,
  letterSpacing: -0.16,
);
  @override
  TextStyle get vsdswBodyMd => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 16.0,
  fontWeight: FontWeight.w400,
  height: 1.7,
  letterSpacing: 0.0,
);
  @override
  TextStyle get vsdswBodySm => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 14.0,
  fontWeight: FontWeight.w400,
  height: 1.7,
  letterSpacing: 0.0,
);
  @override
  TextStyle get vsdswLabelMd => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 16.0,
  fontWeight: FontWeight.w400,
  height: 1.7,
  letterSpacing: 0.0,
);
  @override
  TextStyle get vsdswLabelSm => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 14.0,
  fontWeight: FontWeight.w400,
  height: 1.7,
  letterSpacing: 0.0,
);
  @override
  TextStyle get vsdswLabelXs => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 12.0,
  fontWeight: FontWeight.w400,
  height: 1.2,
  letterSpacing: 0.0,
);
}


class DefaultRadiiTokens extends RadiiTokens {
  @override
  BorderRadius get vsdswRadiusSm => BorderRadius.circular(2.0);
  @override
  BorderRadius get vsdswRadiusmd => BorderRadius.circular(4.0);
  @override
  BorderRadius get vsdswRadiusLg => BorderRadius.circular(8.0);
  @override
  BorderRadius get vsdswRadiusXl => BorderRadius.circular(16.0);
  @override
  BorderRadius get vsdswRadius2xl => BorderRadius.circular(24.0);
  @override
  BorderRadius get vsdswRadius3xl => BorderRadius.circular(40.0);
  @override
  BorderRadius get vsdswRadiusFull => BorderRadius.circular(9999.0);
}


class DefaultShadowTokens extends ShadowTokens {
  @override
  List<BoxShadow> get vsdswShadowNeutralSm => const [
  BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
    spreadRadius: 0.0,
    color: Color(0x29151C32),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowNeutralMd => const [
  BoxShadow(
    offset: Offset(0.0, 4.0),
    blurRadius: 8.0,
    spreadRadius: 0.0,
    color: Color(0x29151C32),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowNeutralLg => const [
  BoxShadow(
    offset: Offset(0.0, 8.0),
    blurRadius: 16.0,
    spreadRadius: 0.0,
    color: Color(0x52151C32),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowNeutralXl => const [
  BoxShadow(
    offset: Offset(0.0, 16.0),
    blurRadius: 24.0,
    spreadRadius: 0.0,
    color: Color(0xA3151C32),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowPrimarySm => const [
  BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
    spreadRadius: 0.0,
    color: Color(0x143C5AAA),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowPrimaryMd => const [
  BoxShadow(
    offset: Offset(0.0, 4.0),
    blurRadius: 8.0,
    spreadRadius: 0.0,
    color: Color(0x293C5AAA),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowPrimaryLg => const [
  BoxShadow(
    offset: Offset(0.0, 8.0),
    blurRadius: 16.0,
    spreadRadius: 0.0,
    color: Color(0x7A3C5AAA),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowPrimaryXl => const [
  BoxShadow(
    offset: Offset(0.0, 16.0),
    blurRadius: 24.0,
    spreadRadius: 0.0,
    color: Color(0x7A3C5AAA),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowSecondarySm => const [
  BoxShadow(
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
    spreadRadius: 0.0,
    color: Color(0x145D80ED),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowSecondaryMd => const [
  BoxShadow(
    offset: Offset(0.0, 4.0),
    blurRadius: 8.0,
    spreadRadius: 0.0,
    color: Color(0xFF000000),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowSecondaryLg => const [
  BoxShadow(
    offset: Offset(0.0, 8.0),
    blurRadius: 16.0,
    spreadRadius: 0.0,
    color: Color(0xFF000000),
  ),
];
  @override
  List<BoxShadow> get vsdswShadowSecondaryXl => const [
  BoxShadow(
    offset: Offset(0.0, 16.0),
    blurRadius: 24.0,
    spreadRadius: 0.0,
    color: Color(0x7A5D80ED),
  ),
];
}


class DefaultMaterialColorTokens extends MaterialColorTokens {
  @override
MaterialColor get vsdswColorSurface => const MaterialColor(0xFFA7ADC0, {
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
