import 'dart:convert';

import 'package:encrypt/encrypt.dart';

/*
 * https://github.com/leocavalcante/encrypt#usage
 *
 *
 * Use "AES/CBC/PKCS5Padding"
 * based on:
 * http://zhuqiaochu.truestudio.tech/dart-java-swift-aes-cbc-pkcs7padding/
 * Java中PKCS5Padding 就是 PKCS7Padding
 *
 * */
aesEncryptWithBase64(String keyStr, String data) {
  final key = Key.fromUtf8(keyStr);
  final iv = IV.fromSecureRandom(16);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(data, iv: iv);
  // "iv.bytes + encrypted.bytes" 不是 AES 加密步驟，是 myViewBoard 自訂的規則
  return base64.encode(iv.bytes + encrypted.bytes);
}
