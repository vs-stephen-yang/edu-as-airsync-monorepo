enum IonResolutionType {
  hd,
  fhd,
}

const deviceResolutionsMap = <String, IonResolutionType>{
  'IFP33': IonResolutionType.hd,
  'CDE30': IonResolutionType.hd,
  // NOTE: see device_feature_adapter.dart's deviceOptions
};

IonResolutionType getCaptureVideoResolution(
  String? deviceType,
  double screenWidth,
  double screenHeight,
) {
  final resolutionType = deviceResolutionsMap[deviceType];
  if (resolutionType != null) {
    return resolutionType;
  }

  const fullHd = 1080.0;

  if (screenHeight / 2 >= fullHd) {
    return IonResolutionType.fhd;
  } else {
    return IonResolutionType.hd;
  }
}
