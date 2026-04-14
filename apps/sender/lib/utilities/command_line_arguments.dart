class CommandLineArguments {
  final String profilesPath;
  final String selectedProfile;

  CommandLineArguments(
      {required this.profilesPath, required this.selectedProfile});

  // usage: --profiles PROFILES --selected-profile SELECTEDPROFILE
  factory CommandLineArguments.parse(List<String> arguments) {
    String profilesPath = '';
    String selectedProfile = '';

    for (int i = 0; i < arguments.length; i++) {
      if (arguments[i] == '--profiles' && i + 1 < arguments.length) {
        profilesPath = arguments[i + 1];
      } else if (arguments[i] == '--selected-profile' &&
          i + 1 < arguments.length) {
        selectedProfile = arguments[i + 1];
      }
    }

    return CommandLineArguments(
      profilesPath: profilesPath,
      selectedProfile: selectedProfile,
    );
  }
}
