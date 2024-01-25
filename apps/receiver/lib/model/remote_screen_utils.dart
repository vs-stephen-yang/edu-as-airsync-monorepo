enum IonResolutionType {
  hd,
  fhd,
}

IonResolutionType getCaptureVideoResolution(
  double screenWidth,
  double screenHeight,
) {
  const fullHd = 1080.0;

  if (screenHeight / 2 >= fullHd) {
    return IonResolutionType.fhd;
  } else {
    return IonResolutionType.hd;
  }
}
