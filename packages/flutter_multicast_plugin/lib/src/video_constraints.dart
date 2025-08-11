class MediaTrackConstraints {
  MediaTrackConstraints(
      {required this.frameRate, required this.height, required this.width});

  /// Properties of video tracks
  int frameRate;
  int height;
  int width;

  // Change to use the constraint data structure in flutter-webrtc itself,
  // this modification breaks the original compatibility of ion-sdk-flutter.
  Map<String, dynamic> toMap() => {
        'width': width,
        'height': height,
        'frameRate': frameRate,
      };
}

class RtpEncoding {
  int maxBitrate;
  String bitrateMode;
  int bitrate;

  RtpEncoding({
    required this.maxBitrate,
    required this.bitrateMode,
    required this.bitrate,
  });
}

class VideoConstraints {
  VideoConstraints({required this.constraints, required this.encodings});

  final MediaTrackConstraints constraints;
  final RtpEncoding encodings;
}

enum Resolution {
  qvga,
  vga,
  shd,
  hd,
  fhd,
  qhd,
}

var videoConstraints = <Resolution, VideoConstraints>{
  Resolution.qvga: VideoConstraints(
      constraints:
          MediaTrackConstraints(width: 320, height: 180, frameRate: 15),
      encodings:
          RtpEncoding(maxBitrate: 150000, bitrate: 150000, bitrateMode: 'CBR')),
  Resolution.vga: VideoConstraints(
      constraints:
          MediaTrackConstraints(width: 640, height: 360, frameRate: 30),
      encodings:
          RtpEncoding(maxBitrate: 500000, bitrate: 500000, bitrateMode: 'CBR')),
  Resolution.shd: VideoConstraints(
      constraints:
          MediaTrackConstraints(width: 960, height: 540, frameRate: 30),
      encodings: RtpEncoding(
          maxBitrate: 1200000, bitrate: 1200000, bitrateMode: 'CBR')),
  Resolution.hd: VideoConstraints(
      constraints:
          MediaTrackConstraints(width: 1280, height: 720, frameRate: 30),
      encodings: RtpEncoding(
          maxBitrate: 2500000, bitrate: 2500000, bitrateMode: 'CBR')),
  Resolution.fhd: VideoConstraints(
      constraints:
          MediaTrackConstraints(width: 1920, height: 1080, frameRate: 30),
      encodings: RtpEncoding(
          maxBitrate: 4000000, bitrate: 4000000, bitrateMode: 'CBR')),
  Resolution.qhd: VideoConstraints(
      constraints:
          MediaTrackConstraints(width: 2560, height: 1440, frameRate: 30),
      encodings: RtpEncoding(
          maxBitrate: 8000000, bitrate: 8000000, bitrateMode: 'CBR')),
};
