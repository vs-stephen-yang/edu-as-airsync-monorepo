enum AirplaySecurity {
  none,
  onscreenCode,
}

class AirplayConfig {
  final String name;

  final AirplaySecurity security;

  const AirplayConfig({
    required this.name,
    required this.security,
  });
}
