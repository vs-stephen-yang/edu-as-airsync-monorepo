import 'dart:math';

String generateOTP(Random random) {
  final randomNumber = random.nextInt(9000) + 1000;
  return randomNumber.toString();
}
