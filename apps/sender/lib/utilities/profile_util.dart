import 'dart:io';
import 'dart:convert';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'command_line_arguments.dart';

class ProfileUtil {
  static Future<List<Profile>> fetchProfiles(String content) async {
    final data = await json.decode(content);
    List<Profile> profiles =
        (data['profiles'] as List).map((i) => Profile.fromJson(i)).toList();
    return profiles;
  }

  static Future<List<Profile>> fetchProfilesFromBundle() async {
    try {
      final String content =
          await rootBundle.loadString('assets/profiles.json');
      return await fetchProfiles(content);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Profile>> fetchProfilesFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      return await fetchProfiles(content);
    } catch (e) {
      return [];
    }
  }

  static saveSelectedProfile(String selectedProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("SelectedProfile", selectedProfile);
  }

  static Future<ProfileStore> loadProfileStore(List<String> args) async {
    // load selected profile from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedProfile = prefs.getString("SelectedProfile") ??
        ProfileStore.defaultSelectedProfile;

    // load profile from command line arguments
    // if not found, load bundle profile
    final CommandLineArguments arguments = CommandLineArguments.parse(args);

    if (arguments.selectedProfile.isNotEmpty) {
      selectedProfile = arguments.selectedProfile;
    }

    List<Profile> profiles;
    if (arguments.profilesPath.isNotEmpty) {
      profiles =
          await ProfileUtil.fetchProfilesFromFile(arguments.profilesPath);
    } else {
      profiles = await ProfileUtil.fetchProfilesFromBundle();
    }

    return ProfileStore(profiles: profiles, selectedProfile: selectedProfile);
  }
}
