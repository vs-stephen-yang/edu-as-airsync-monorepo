// the values must be same with the ones defined in android\src\main\cpp\flutter_mirror.cpp
enum AirplaySecurity {
  none,
  onscreenCode,
  //password
}

class AirplayConfig {
  final String name;

  final AirplaySecurity security;

  const AirplayConfig({
    required this.name,
    required this.security,
  });
}
