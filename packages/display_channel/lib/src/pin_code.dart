import 'dart:core';

class PinCode {
  static const maxPasscode = 120;

  String host; //IPv4
  int passcode;

  PinCode(
    this.host,
    this.passcode,
  );
}

// Constants for radix and length of PinCode
const pinCodeRadix = 36; // 26 letters + 10 numbers
const pinCodeLength = 6;

// Private IP ranges for different classes
const rangeOfPrivateClass = [
  16777216, // Class A 10.0.0.0 – 10.255.255.255 (24-bit block)
  1048576, // Class B 172.16.0.0 – 172.31.255.255 (20-bit block)
  65536, // Class C 192.168.0.0 – 192.168.255.255 (16-bit block)
];

// Prefixes of private IP classes
const prefixOfPrivateIpClass = [
  '10', // Class A
  '172', // Class B
  '192.168', // Class C
];

const baseOfPrivateIpClass = [
  0x0A000000, // Class A
  0xAC100000,
  0xC0A80000,
];

const maskOfPrivateIpClass = [
  0x00ffffff, // Class A
  0x000fffff,
  0x0000ffff,
];

// calculates the total range of private IP addresses.
int getRangeOfPrivateIp() {
  return rangeOfPrivateClass.reduce((sum, element) => sum + element);
}

// Calculates the offset of private IP class at a given index
int getOffsetOfPrivateClass(int index) {
  int sum = 0;
  for (var i = 0; i < index; i++) {
    sum += rangeOfPrivateClass[i];
  }
  return sum;
}

// Finds the class index of a given offset within the private IP ranges
int findIpClassIndexByOffset(int offset) {
  int sum = 0;

  for (var i = 0; i < rangeOfPrivateClass.length; i++) {
    sum += rangeOfPrivateClass[i];

    if (sum > offset) {
      return i;
    }
  }
  return -1;
}

// Finds the class index of a given IPv4 host
int getClassOfIpv4(String host) {
  return prefixOfPrivateIpClass.indexWhere(
    (prefix) => host.startsWith(prefix),
  );
}

// Converts an IPv4 address string to an integer
int ipv4ToInt(String ipAddress) {
  List<String> parts = ipAddress.split('.');
  int intAddress = 0;

  for (int i = 0; i < 4; i++) {
    intAddress = (intAddress << 8) + int.parse(parts[i]);
  }

  return intAddress;
}

// Converts an integer back to an IPv4 address string
String intToIPv4(int intAddress) {
  // Extracting octets using bitwise operations
  int octet1 = (intAddress >> 24) & 0xFF;
  int octet2 = (intAddress >> 16) & 0xFF;
  int octet3 = (intAddress >> 8) & 0xFF;
  int octet4 = intAddress & 0xFF;

  // Constructing the IP address string
  return '$octet1.$octet2.$octet3.$octet4';
}

String formatPinCode(int code) {
  return code
      .toRadixString(pinCodeRadix)
      .toUpperCase()
      .padLeft(pinCodeLength, '0');
}

String encodePinCode(PinCode pinCode) {
  assert(pinCode.passcode <= PinCode.maxPasscode);

  int classIndex = getClassOfIpv4(pinCode.host);

  int intHost = ipv4ToInt(pinCode.host);

  int maskedIntHost = intHost & maskOfPrivateIpClass[classIndex];

  int offsetOfClass = getOffsetOfPrivateClass(classIndex);

  final totalIpRange = getRangeOfPrivateIp();

  int code = totalIpRange * pinCode.passcode + maskedIntHost + offsetOfClass;

  return formatPinCode(code);
}

PinCode decodePinCode(String string) {
  int code = int.parse(string, radix: pinCodeRadix);

  final totalIpRange = getRangeOfPrivateIp();

  int quotient = code ~/ totalIpRange;
  int remainder = code % totalIpRange;

  int classIndex = findIpClassIndexByOffset(remainder);

  int offsetOfClass = getOffsetOfPrivateClass(classIndex);

  int maskedIntHost = remainder - offsetOfClass;

  int intHost = maskedIntHost + baseOfPrivateIpClass[classIndex];
  String host = intToIPv4(intHost);

  return PinCode(host, quotient);
}
