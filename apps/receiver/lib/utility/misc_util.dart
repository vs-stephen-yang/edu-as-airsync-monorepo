import 'dart:math';

String generateOTP(Random random) {
  final randomNumber = random.nextInt(10000);
  return randomNumber.toString().padLeft(4, '0');
}
