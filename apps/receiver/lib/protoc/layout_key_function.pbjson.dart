///
//  Generated code. Do not modify.
//  source: layout_key_function.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use layoutKeyFunctionDescriptor instead')
const LayoutKeyFunction$json = const {
  '1': 'LayoutKeyFunction',
  '2': const [
    const {'1': 'UNKNOWN', '2': 0},
    const {'1': 'CONTROL', '2': 1},
    const {'1': 'ALT', '2': 2},
    const {'1': 'SHIFT', '2': 3},
    const {'1': 'META', '2': 4},
    const {'1': 'ALT_GR', '2': 5},
    const {'1': 'MOD5', '2': 6},
    const {'1': 'COMPOSE', '2': 7},
    const {'1': 'OPTION', '2': 61},
    const {'1': 'COMMAND', '2': 62},
    const {'1': 'SEARCH', '2': 63},
    const {'1': 'NUM_LOCK', '2': 8},
    const {'1': 'CAPS_LOCK', '2': 9},
    const {'1': 'SCROLL_LOCK', '2': 10},
    const {'1': 'BACKSPACE', '2': 11},
    const {'1': 'ENTER', '2': 12},
    const {'1': 'TAB', '2': 13},
    const {'1': 'INSERT', '2': 14},
    const {'1': 'DELETE_', '2': 15},
    const {'1': 'HOME', '2': 16},
    const {'1': 'END', '2': 17},
    const {'1': 'PAGE_UP', '2': 18},
    const {'1': 'PAGE_DOWN', '2': 19},
    const {'1': 'CLEAR', '2': 20},
    const {'1': 'ARROW_UP', '2': 21},
    const {'1': 'ARROW_DOWN', '2': 22},
    const {'1': 'ARROW_LEFT', '2': 23},
    const {'1': 'ARROW_RIGHT', '2': 24},
    const {'1': 'F1', '2': 25},
    const {'1': 'F2', '2': 26},
    const {'1': 'F3', '2': 27},
    const {'1': 'F4', '2': 28},
    const {'1': 'F5', '2': 29},
    const {'1': 'F6', '2': 30},
    const {'1': 'F7', '2': 31},
    const {'1': 'F8', '2': 32},
    const {'1': 'F9', '2': 33},
    const {'1': 'F10', '2': 34},
    const {'1': 'F11', '2': 35},
    const {'1': 'F12', '2': 36},
    const {'1': 'F13', '2': 37},
    const {'1': 'F14', '2': 38},
    const {'1': 'F15', '2': 39},
    const {'1': 'F16', '2': 40},
    const {'1': 'F17', '2': 41},
    const {'1': 'F18', '2': 42},
    const {'1': 'F19', '2': 43},
    const {'1': 'F20', '2': 44},
    const {'1': 'F21', '2': 45},
    const {'1': 'F22', '2': 46},
    const {'1': 'F23', '2': 47},
    const {'1': 'F24', '2': 48},
    const {'1': 'ESCAPE', '2': 49},
    const {'1': 'CONTEXT_MENU', '2': 50},
    const {'1': 'PAUSE', '2': 51},
    const {'1': 'PRINT_SCREEN', '2': 52},
    const {'1': 'HANKAKU_ZENKAKU_KANJI', '2': 53},
    const {'1': 'HENKAN', '2': 54},
    const {'1': 'MUHENKAN', '2': 55},
    const {'1': 'KATAKANA_HIRAGANA_ROMAJI', '2': 56},
    const {'1': 'KANA', '2': 57},
    const {'1': 'EISU', '2': 58},
    const {'1': 'HAN_YEONG', '2': 59},
    const {'1': 'HANJA', '2': 60},
  ],
};

/// Descriptor for `LayoutKeyFunction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List layoutKeyFunctionDescriptor = $convert.base64Decode('ChFMYXlvdXRLZXlGdW5jdGlvbhILCgdVTktOT1dOEAASCwoHQ09OVFJPTBABEgcKA0FMVBACEgkKBVNISUZUEAMSCAoETUVUQRAEEgoKBkFMVF9HUhAFEggKBE1PRDUQBhILCgdDT01QT1NFEAcSCgoGT1BUSU9OED0SCwoHQ09NTUFORBA+EgoKBlNFQVJDSBA/EgwKCE5VTV9MT0NLEAgSDQoJQ0FQU19MT0NLEAkSDwoLU0NST0xMX0xPQ0sQChINCglCQUNLU1BBQ0UQCxIJCgVFTlRFUhAMEgcKA1RBQhANEgoKBklOU0VSVBAOEgsKB0RFTEVURV8QDxIICgRIT01FEBASBwoDRU5EEBESCwoHUEFHRV9VUBASEg0KCVBBR0VfRE9XThATEgkKBUNMRUFSEBQSDAoIQVJST1dfVVAQFRIOCgpBUlJPV19ET1dOEBYSDgoKQVJST1dfTEVGVBAXEg8KC0FSUk9XX1JJR0hUEBgSBgoCRjEQGRIGCgJGMhAaEgYKAkYzEBsSBgoCRjQQHBIGCgJGNRAdEgYKAkY2EB4SBgoCRjcQHxIGCgJGOBAgEgYKAkY5ECESBwoDRjEwECISBwoDRjExECMSBwoDRjEyECQSBwoDRjEzECUSBwoDRjE0ECYSBwoDRjE1ECcSBwoDRjE2ECgSBwoDRjE3ECkSBwoDRjE4ECoSBwoDRjE5ECsSBwoDRjIwECwSBwoDRjIxEC0SBwoDRjIyEC4SBwoDRjIzEC8SBwoDRjI0EDASCgoGRVNDQVBFEDESEAoMQ09OVEVYVF9NRU5VEDISCQoFUEFVU0UQMxIQCgxQUklOVF9TQ1JFRU4QNBIZChVIQU5LQUtVX1pFTktBS1VfS0FOSkkQNRIKCgZIRU5LQU4QNhIMCghNVUhFTktBThA3EhwKGEtBVEFLQU5BX0hJUkFHQU5BX1JPTUFKSRA4EggKBEtBTkEQORIICgRFSVNVEDoSDQoJSEFOX1lFT05HEDsSCQoFSEFOSkEQPA==');
