// lib/obf_decoder.dart
import 'dart:convert';
import 'dart:io'; // ZLibCodec 需要；Flutter Web 不支援
import 'dart:typed_data';

const _blockSize = 512; // 與編碼端一致
const _stdB64 =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
const _customB64 =
    'NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm5678901234+/';

String _fromCustomB64(String s) {
  final out = StringBuffer();
  for (final ch in s.codeUnits) {
    if (ch == '='.codeUnitAt(0)) {
      out.writeCharCode(ch);
    } else {
      final idx = _customB64.indexOf(String.fromCharCode(ch));
      out.write(_stdB64[idx]);
    }
  }
  return out.toString();
}

int _fnv1a32(String s) {
  const int FNV_PRIME = 0x01000193;
  int hash = 0x811C9DC5;
  for (final b in utf8.encode(s)) {
    hash ^= b;
    hash = (hash * FNV_PRIME) & 0xFFFFFFFF;
  }
  return hash;
}

class _XorShift32 {
  int _x;

  _XorShift32(this._x);

  int nextUint32() {
    var x = _x;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= (x >> 17);
    x ^= (x << 5) & 0xFFFFFFFF;
    _x = x & 0xFFFFFFFF;
    return _x;
  }

  int nextByte() => nextUint32() & 0xFF;
}

Uint8List _unshuffleBlocks(Uint8List data, int blockSize, _XorShift32 rng) {
  assert(data.length % blockSize == 0);
  final nBlocks = data.length ~/ blockSize;

  // 生成與編碼端相同的 perm
  final perm = List<int>.generate(nBlocks, (i) => i);
  for (int i = nBlocks - 1; i > 0; i--) {
    final j = rng.nextUint32() % (i + 1);
    final t = perm[i];
    perm[i] = perm[j];
    perm[j] = t;
  }

  final out = Uint8List(data.length);
  for (int dstBlock = 0; dstBlock < nBlocks; dstBlock++) {
    final origBlock = perm[dstBlock]; // 這個洗牌後位置，原本來自哪一塊
    final srcStart = dstBlock * blockSize; // 在「洗牌後」資料中的位置
    final dstStart = origBlock * blockSize; // 放回「原始順序」的位置
    out.setRange(dstStart, dstStart + blockSize,
        data.sublist(srcStart, srcStart + blockSize));
  }
  return out;
}

/// 將 .obf64 字串還原為原始位元組
Uint8List decodeObf64String(String obf64, {required String passphrase}) {
  // 1) 轉回標準 Base64 再 decode
  final stdB64 = _fromCustomB64(obf64);
  final shuffled = base64Decode(stdB64);

  // 2) 反洗牌
  final seed = (_fnv1a32(passphrase) ^
          shuffled.length /* will include padding */ ^
          _blockSize) &
      0xFFFFFFFF;
  final unshuffled = _unshuffleBlocks(shuffled, _blockSize, _XorShift32(seed));

  // 3) XOR 還原
  final rng = _XorShift32(seed);
  for (int i = 0; i < unshuffled.length; i++) {
    unshuffled[i] = unshuffled[i] ^ rng.nextByte();
  }

  // 4) 去掉 4-byte 長度標頭與 padding
  if (unshuffled.length < 4) {
    throw const FormatException('Invalid payload');
  }
  final bd = ByteData.sublistView(unshuffled, 0, 4);
  final compLen = bd.getUint32(0, Endian.big);
  if (4 + compLen > unshuffled.length) {
    throw const FormatException('Corrupted length header');
  }
  final compressed = unshuffled.sublist(4, 4 + compLen);

  // 5) 解壓縮
  final clear = ZLibCodec().decode(compressed);
  return Uint8List.fromList(clear);
}
