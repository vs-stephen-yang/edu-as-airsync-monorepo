class Profile {
  final String name;
  final List<Preset> presets;

  Profile({required this.name, required this.presets});

  factory Profile.fromJson(Map<String, dynamic> json) {
    var presetsJson = json['presets'] as List;
    List<Preset> presetsList =
        presetsJson.map((i) => Preset.fromJson(i)).toList();

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

  Preset(
      {required this.codec,
      required this.platform,
      required this.description,
      required this.parameters});

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

class ProfileStore {
  // must match the profile name in the profiles.json
  static const String videoQualityFirstProfile = 'video_quality_first';
  static const String videoSmoothnessFirstProfile = 'video_smoothness_first';
  static const String defaultSelectedProfile =
      videoQualityFirstProfile; // by default

  final List<Profile> profiles;
  String selectedProfile = '';

  ProfileStore({required this.profiles, required this.selectedProfile});

  void setSelectedProfile(String profile) {
    selectedProfile = profile;
  }

  Profile getSelectedProfile() {
    return profiles.firstWhere(
      (element) => element.name == selectedProfile,
      orElse: () => profiles
          .firstWhere((element) => element.name == defaultSelectedProfile),
    );
  }
}
