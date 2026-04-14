class StreamRocData {
  final int videoRoc;
  final int audioRoc;

  StreamRocData({
    required this.videoRoc,
    required this.audioRoc,
  });

  factory StreamRocData.fromMap(Map<String, dynamic> map) {
    return StreamRocData(
      videoRoc: map['video'] as int,
      audioRoc: map['audio'] as int,
    );
  }
}