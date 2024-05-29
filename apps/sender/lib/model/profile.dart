class Profile {
  final String name;
  final List<Preset> presets;

  Profile({required this.name, required this.presets});

  factory Profile.fromJson(Map<String, dynamic> json) {
    var presetsJson = json['presets'] as List;
    List<Preset> presetsList = presetsJson.map((i) => Preset.fromJson(i)).toList();

    return Profile(
      name: json['name'],
      presets: presetsList,
    );
  }
}

class Preset {
  final String codec;
  final String platform;
  final String description;
  final Parameters parameters;

  Preset({required this.codec, required this.platform, required this.description, required this.parameters});

  factory Preset.fromJson(Map<String, dynamic> json) {
    return Preset(
      codec: json['codec'],
      platform: json['platform'],
      description: json['description'],
      parameters: Parameters.fromJson(json['parameters']),
    );
  }
}

class Parameters {
  final int minBitrateKbps;
  final int maxBitrateKbps;

  Parameters({required this.minBitrateKbps, required this.maxBitrateKbps});

  factory Parameters.fromJson(Map<String, dynamic> json) {
    return Parameters(
      minBitrateKbps: json['minBitrateKbps'],
      maxBitrateKbps: json['maxBitrateKbps'],
    );
  }
}
