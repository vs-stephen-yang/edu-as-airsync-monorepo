import 'dart:io';
import 'dart:convert';
import 'package:display_cast_flutter/model/profile.dart';
import 'package:flutter/services.dart';

class ProfileUtil {
  static Future<List<Profile>> fetchProfiles(String content) async {
    final data = await json.decode(content);
    List<Profile> profiles = (data['profiles'] as List).map((i) => Profile.fromJson(i)).toList();
    return profiles;
  }

  static Future<List<Profile>> fetchProfilesFromBundle() async {
    try {
      final String content = await rootBundle.loadString('assets/profiles.json');
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
}