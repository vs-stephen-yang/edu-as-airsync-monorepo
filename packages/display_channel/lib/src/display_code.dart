class IpIndex {
  int segmentIndex;
  int ipIndex;

  IpIndex(
    this.segmentIndex,
    this.ipIndex,
  );
}

class DisplayCode {
  String ipAddress;
  int instanceIndex;

  DisplayCode(
    this.ipAddress,
    this.instanceIndex,
  );

  bool hasIpAddress() => ipAddress.isNotEmpty;
  bool hasInstanceIndex() => instanceIndex != 0;

  bool isDual() => hasIpAddress() && hasInstanceIndex();
}

const displayCodeRadix = 36; // 26 letters + 10 numbers

enum Ipv4Class {
  classC,
  classB,
  classA,
}

// Class C 192.168.0.0 – 192.168.255.255 (16-bit block)
const numberOfClassC = 65536;
// Class B 172.16.0.0 – 172.31.255.255 (20-bit block)
const numberOfClassB = 1048576;
// Class A 10.0.0.0 – 10.255.255.255 (24-bit block)
const numberOfClassA = 16777216;

const baseOfPrivateIpClass = [
  0xC0A80000, // Class C
  0xAC100000, // Class B
  0x0A000000, // Class A
];

const maskOfPrivateIpClass = [
  0x0000ffff, // Class C
  0x000fffff, // Class B
  0x00ffffff, // Class A
];

const ipIndexOffsetOfClasses = [
  0, // Class C
  numberOfClassC, // Class B
  0, // Class A
];
const segmentIndexOfClasses = [
  0, // Class C
  0, // Class B
  1, // Class A
];

// Display code is divided into chunks
// Each chunk covers 1,000,000 instances
const instancesPerChunk = 1000000;

// Each chunk is divided into two segments
final segmentOffsets = [
  // Segment 0 contains IP address in class B and class C
  BigInt.from(0),
  // Segment 1 contains IP address in class A
  BigInt.from(instancesPerChunk) * BigInt.from(numberOfClassB + numberOfClassC),
];

// The number of IP in each segment
const ipCountOfSegments = [
  numberOfClassB + numberOfClassC,
  numberOfClassA,
];

final chunkSize = BigInt.from(instancesPerChunk) *
    BigInt.from(numberOfClassA + numberOfClassB + numberOfClassC);

// Prefixes of private IP classes
const prefixOfPrivateIpClass = {
  '192.168': Ipv4Class.classC, // Class C
  '172': Ipv4Class.classB, // Class B
  '10': Ipv4Class.classA, // Class A
};

// Finds the class index of a given IPv4 address
Ipv4Class? getClassOfIpAddress(String ipAddress) {
  for (final entry in prefixOfPrivateIpClass.entries) {
    if (ipAddress.startsWith(entry.key)) {
      return entry.value;
    }
  }
  return null;
}

Ipv4Class getClassFromIpIndex(IpIndex ipIndex) {
  if (ipIndex.segmentIndex == 1) {
    return Ipv4Class.classA;
  } else {
    // class C and class B
    return ipIndex.ipIndex < numberOfClassC
        ? Ipv4Class.classC
        : Ipv4Class.classB;
  }
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

IpIndex? mapIpAddressToIndex(String ipAddress) {
  Ipv4Class? ipClass = getClassOfIpAddress(ipAddress);
  if (ipClass == null) {
    return null;
  }

  int ipAddressInt = ipv4ToInt(ipAddress);
  int ipAddressIndex = ipAddressInt & maskOfPrivateIpClass[ipClass.index];

  return IpIndex(
    segmentIndexOfClasses[ipClass.index],
    ipIndexOffsetOfClasses[ipClass.index] + ipAddressIndex,
  );
}

String mapIpIndexToIpAddress(IpIndex ipIndex) {
  Ipv4Class ipClass = getClassFromIpIndex(ipIndex);

  final ipAddressIndex =
      ipIndex.ipIndex - ipIndexOffsetOfClasses[ipClass.index];

  final ipAddressInt = ipAddressIndex + baseOfPrivateIpClass[ipClass.index];
  return intToIPv4(ipAddressInt);
}

// locate the segment to which the index belongs.
int findSegmentIndex(BigInt indexInChunk) {
  // A chunk contains two segments
  return indexInChunk < segmentOffsets[1] ? 0 : 1;
}

String? encodeDisplayCode(DisplayCode code) {
  final ipIndex = mapIpAddressToIndex(code.ipAddress);
  if (ipIndex == null) {
    return null;
  }

  final chunkIndex = code.instanceIndex ~/ instancesPerChunk;
  final instanceIndexInChunk = code.instanceIndex % instancesPerChunk;

  final chunkOffet = BigInt.from(chunkIndex) * chunkSize;

  final segmentOffset = segmentOffsets[ipIndex.segmentIndex];

  final indexInSegment = BigInt.from(instanceIndexInChunk) *
          BigInt.from(ipCountOfSegments[ipIndex.segmentIndex]) +
      BigInt.from(ipIndex.ipIndex);

  final displayCodeIndex = chunkOffet + segmentOffset + indexInSegment;

  return displayCodeIndex.toRadixString(displayCodeRadix).toUpperCase();
}

DisplayCode decodeDisplayCode(String code) {
  BigInt displayCodeIndex = BigInt.parse(code, radix: displayCodeRadix);

  final chunkIndex = displayCodeIndex ~/ chunkSize;

  final indexInChunk = displayCodeIndex % chunkSize;

  final segmentIndex = findSegmentIndex(indexInChunk);
  final indexInSegment = indexInChunk - segmentOffsets[segmentIndex];

  final instanceIndexInChunk =
      indexInSegment ~/ BigInt.from(ipCountOfSegments[segmentIndex]);
  final ipIndex = indexInSegment % BigInt.from(ipCountOfSegments[segmentIndex]);

  final ipAddress = mapIpIndexToIpAddress(
    IpIndex(segmentIndex, ipIndex.toInt()),
  );

  final instanceIndex =
      instancesPerChunk * chunkIndex.toInt() + instanceIndexInChunk.toInt();

  return DisplayCode(
    ipAddress,
    instanceIndex,
  );
}
