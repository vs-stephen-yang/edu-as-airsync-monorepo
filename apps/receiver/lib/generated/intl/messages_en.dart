// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "eula_agree": MessageLookupByLibrary.simpleMessage("I Agree"),
        "eula_disagree": MessageLookupByLibrary.simpleMessage("I Disagree"),
        "eula_title":
            MessageLookupByLibrary.simpleMessage("myViewBoard Display EULA"),
        "main_content_display_code":
            MessageLookupByLibrary.simpleMessage("Display Code"),
        "main_content_one_time_password":
            MessageLookupByLibrary.simpleMessage("One Time Password"),
        "main_content_one_time_password_get_fail":
            MessageLookupByLibrary.simpleMessage(
                "Failed to refresh password.\nPlease wait for 30 seconds before retrying."),
        "main_content_scan_or": MessageLookupByLibrary.simpleMessage("or"),
        "main_content_scan_to_enroll": MessageLookupByLibrary.simpleMessage(
            "To share screen: Use the above URL, Display Code, and One Time Password.\nOptional: IT Admin can use Companion App to scan and enroll"),
        "main_get_display_code_failure": MessageLookupByLibrary.simpleMessage(
            "Failed to get display code. Wait for network connectivity to resume, or restart the app."),
        "main_language_name": MessageLookupByLibrary.simpleMessage("English"),
        "main_language_title": MessageLookupByLibrary.simpleMessage("Language"),
        "main_limit_time_message":
            MessageLookupByLibrary.simpleMessage("5 minutes left"),
        "main_privilege_close": MessageLookupByLibrary.simpleMessage("Close"),
        "main_privilege_message": MessageLookupByLibrary.simpleMessage(
            "This is a Display Advanced feature. Please contact your IT administrator for more information."),
        "main_register_display_code_failure":
            MessageLookupByLibrary.simpleMessage(
                "Display App registration failed. Please try again."),
        "main_split_screen_question": MessageLookupByLibrary.simpleMessage(
            "Click the above toggle for Split Screen Mode. Up to 4 participants can present at once."),
        "main_split_screen_title":
            MessageLookupByLibrary.simpleMessage("Split Screen"),
        "main_split_screen_waiting": MessageLookupByLibrary.simpleMessage(
            "Split screen enabled. Waiting for presenter to share screen..."),
        "main_status_go_background": MessageLookupByLibrary.simpleMessage(
            "Display app is running in the background."),
        "main_status_no_network": MessageLookupByLibrary.simpleMessage(
            "Unstable network connection.\nPlease check your connectivity status."),
        "main_status_remaining_time":
            MessageLookupByLibrary.simpleMessage("%02d min : %02d sec"),
        "main_thanks_content": MessageLookupByLibrary.simpleMessage(
            "Thank you for using myViewBoard Display."),
        "main_wait_title": MessageLookupByLibrary.simpleMessage(
            "Waiting for presenter to share screen..."),
        "main_wait_up_next": MessageLookupByLibrary.simpleMessage("UP NEXT"),
        "main_whats_new_content": MessageLookupByLibrary.simpleMessage(
            "New Display Advanced features\n1.\tDisplay enrollment as an entity instance: \n    i.\tEntity IT Admin can use the Companion app to scan a QR code to complete a Display enrollment.\n    ii.\tEntity IT Admin can grant or revoke Display Advanced licenses after signing into myviewboard.com and going to Entity Management > Display.\n2.\tModerator Mode: \n    i.\tA moderator can add up to 6 presenters and remove them at any time. \n    ii.\tThe moderator can select up to 4 presenters to share their screens.\n    iii.\tThe moderator can start or stop any presenter\'s screen sharing.\n3.\tSplit Screen Mode: \n    i.\tUp to 4 presenters can share their screens simultaneously.\n\n"),
        "main_whats_new_title":
            MessageLookupByLibrary.simpleMessage("What’s New on Display?"),
        "moderator_activate": MessageLookupByLibrary.simpleMessage("Activate"),
        "moderator_activate_split_screen": MessageLookupByLibrary.simpleMessage(
            "Click the above toggle for Split Screen Mode. Up to 4 participants can present at once."),
        "moderator_cancel": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "moderator_confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "moderator_deactivate_split_screen": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to end this split screen session? All screens currently shared will be terminated."),
        "moderator_exit": MessageLookupByLibrary.simpleMessage("EXIT"),
        "moderator_exit_dialog": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to end this moderator session? All presenters will be removed."),
        "moderator_presentersLimit": MessageLookupByLibrary.simpleMessage(
            "Click the above toggle for Moderator Mode. Up to 6 presenters can join."),
        "moderator_presentersList":
            MessageLookupByLibrary.simpleMessage("Presenters"),
        "moderator_remove": MessageLookupByLibrary.simpleMessage("REMOVE"),
        "moderator_verifyCode_fail": MessageLookupByLibrary.simpleMessage(
            "Something went wrong. Please try again."),
        "vbs_ota_progress_msg":
            MessageLookupByLibrary.simpleMessage("Downloading system updates")
      };
}
