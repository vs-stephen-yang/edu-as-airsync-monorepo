// tool/encode_to_b64.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const _blockSize = 512; // 與解碼端一致
const _stdB64 =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
const _customB64 =
    'NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm5678901234+/';

void _mapStdToCustomB64(StringBuffer out, String stdB64) {
  for (final ch in stdB64.codeUnits) {
    if (ch == '='.codeUnitAt(0)) {
      out.writeCharCode(ch);
    } else {
      final idx = _stdB64.indexOf(String.fromCharCode(ch));
      out.write(_customB64[idx]);
    }
  }
}

String _toCustomB64(Uint8List bytes) {
  final s = base64Encode(bytes);
  final buf = StringBuffer();
  _mapStdToCustomB64(buf, s);
  return buf.toString();
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

Uint8List _shuffleBlocks(Uint8List data, int blockSize, _XorShift32 rng) {
  assert(data.length % blockSize == 0);
  final nBlocks = data.length ~/ blockSize;
  final indices = List<int>.generate(nBlocks, (i) => i);
  // 產生排列
  for (int i = nBlocks - 1; i > 0; i--) {
    final j = rng.nextUint32() % (i + 1);
    final t = indices[i];
    indices[i] = indices[j];
    indices[j] = t;
  }
  final out = Uint8List(data.length);
  for (int dstBlock = 0; dstBlock < nBlocks; dstBlock++) {
    final srcBlock = indices[dstBlock];
    final srcStart = srcBlock * blockSize;
    final dstStart = dstBlock * blockSize;
    out.setRange(dstStart, dstStart + blockSize,
        data.sublist(srcStart, srcStart + blockSize));
  }
  return out;
}

///  dart run tool/encode_to_b64.dart tool/BlackHole2ch-0.6.1.pkg tool/driver.b64 airsync
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
        'Usage: dart tool/encode_to_b64.dart <input_file> <output.obf64> [passphrase]');
    exit(64);
  }
  final input = File(args[0]);
  final output = File(args[1]);
  final passphrase = args.length >= 3 ? args[2] : 'vsc-obf-key-1'; // 請替換

  // 讀檔
  final raw = await input.readAsBytes();

  // 1) 壓縮
  final compressed = ZLibCodec(level: 9).encode(raw);

  // 2) 在前面放 4-byte（大端序）原始長度標頭
  final bd = ByteData(4)..setUint32(0, compressed.length, Endian.big);
  final withLen = Uint8List(4 + compressed.length);
  withLen.setRange(0, 4, bd.buffer.asUint8List());
  withLen.setRange(4, 4 + compressed.length, compressed);

  // 3) 補齊至 blockSize 的整數倍（確保每塊等長）
  final padLen = (_blockSize - (withLen.length % _blockSize)) % _blockSize;
  final payload = Uint8List(withLen.length + padLen);
  payload.setRange(0, withLen.length, withLen);
  if (padLen > 0) {
    final rnd = Random(); // padding 內容無需可重現，解碼時會丟棄
    for (int i = withLen.length; i < payload.length; i++) {
      payload[i] = rnd.nextInt(256);
    }
  }

  // 4) XOR（PRNG 生成位元組流）
  final seed =
      (_fnv1a32(passphrase) ^ payload.length ^ _blockSize) & 0xFFFFFFFF;
  final rng = _XorShift32(seed);
  final xored = Uint8List(payload.length);
  for (int i = 0; i < payload.length; i++) {
    xored[i] = payload[i] ^ rng.nextByte();
  }

  // 5) 分塊洗牌（所有塊等長，安全）
  final shuffled = _shuffleBlocks(xored, _blockSize, _XorShift32(seed));

  // 6) 標準 Base64 -> 自訂字母表
  final obf64 = _toCustomB64(shuffled);

  await output.writeAsString(obf64);
  stdout.writeln('OK (obf64): ${input.path} -> ${output.path}');
}
