// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Language`
  String get main_language_title {
    return Intl.message(
      'Language',
      name: 'main_language_title',
      desc: '',
      args: [],
    );
  }

  /// `Display Code *`
  String get present_display_code {
    return Intl.message(
      'Display Code *',
      name: 'present_display_code',
      desc: '',
      args: [],
    );
  }

  /// `*Display Code contains 9-10 digits`
  String get present_display_code_description {
    return Intl.message(
      '*Display Code contains 9-10 digits',
      name: 'present_display_code_description',
      desc: '',
      args: [],
    );
  }

  /// `One Time Password *`
  String get present_otp_code {
    return Intl.message(
      'One Time Password *',
      name: 'present_otp_code',
      desc: '',
      args: [],
    );
  }

  /// `*One Time Password contains 4 digits`
  String get present_otp_code_description {
    return Intl.message(
      '*One Time Password contains 4 digits',
      name: 'present_otp_code_description',
      desc: '',
      args: [],
    );
  }

  /// `PRESENT`
  String get present_start {
    return Intl.message(
      'PRESENT',
      name: 'present_start',
      desc: '',
      args: [],
    );
  }

  /// `Please fill out this field.`
  String get present_fill_out {
    return Intl.message(
      'Please fill out this field.',
      name: 'present_fill_out',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
