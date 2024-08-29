import 'dart:io';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/providers/channel_provider.dart';
import 'package:display_flutter/providers/instance_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class V3Instruction extends StatefulWidget {
  const V3Instruction({super.key, this.isQuickConnect = false});

  final bool isQuickConnect;

  @override
  State<StatefulWidget> createState() => _V3InstructionState();
}

class _V3InstructionState extends State<V3Instruction> {
  static ConnectivityResult _lastConnectivityResult = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChannelProvider, InstanceInfoProvider>(
        builder: (_, channelProvider, instanceInfoProvider, __) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: widget.isQuickConnect
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (!widget.isQuickConnect)
            AutoSizeText(
              S.of(context).v3_instruction_share_screen,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: context.tokens.color.vsdslColorSurface600,
                letterSpacing: -0.48,
                height: 1.3,
              ),
            ),
          if (!widget.isQuickConnect)
            SizedBox(height: context.tokens.spacing.vsdslSpacing5xl.top),
          if (widget.isQuickConnect)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: const Svg('assets/images/ic_screen.svg'),
                  width: 27,
                  height: 27,
                  color: context.tokens.color.vsdslColorSurface600,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: context.tokens.spacing.vsdslSpacingSm.left),
                  child: Consumer<InstanceInfoProvider>(
                    builder: (_, provider, __) {
                      return AutoSizeText(
                        provider.deviceName,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: context.tokens.color.vsdslColorSurface600,
                          letterSpacing: -0.48,
                          height: 1.3,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          if (widget.isQuickConnect)
            SizedBox(height: context.tokens.spacing.vsdslSpacing4xl.top),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Image(
                image: Svg('assets/images/ic_item1.svg'),
                height: 27,
                width: 27,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: context.tokens.spacing.vsdslSpacingMd.left),
                child: FutureBuilder(
                  future: checkInternetConnection(),
                  builder: (context, snapshot) {
                    bool isInternet = false;
                    if (snapshot.hasData) {
                      isInternet = snapshot.data as bool;
                    }
                    return AutoSizeText.rich(
                      _buildTextSpan(
                        fullText: isInternet
                            ? S.of(context).v3_instruction1a
                            : S.of(context).v3_instruction1b,
                        formatTexts: ['airsync.net'],
                        formatStyle: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: context.tokens.color.vsdslColorSurface600,
                          letterSpacing: -0.48,
                          height: 1.3,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                        color: context.tokens.color.vsdslColorSurface600,
                        letterSpacing: -0.48,
                        height: 1.3,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Image(
                image: Svg('assets/images/ic_item2.svg'),
                height: 27,
                width: 27,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: context.tokens.spacing.vsdslSpacingMd.left),
                child: AutoSizeText(
                  S.of(context).v3_instruction2,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    color: context.tokens.color.vsdslColorSurface600,
                    letterSpacing: -0.48,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
          Padding(
            padding: widget.isQuickConnect
                ? EdgeInsets.zero
                : const EdgeInsets.only(left: 35),
            child: AutoSizeText(
              _getDisplayCodeVisualIdentity(instanceInfoProvider.displayCode),
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w700,
                color: context.tokens.color.vsdslColorSurface700,
                letterSpacing: 5.76,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacing3xl.top),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Image(
                image: Svg('assets/images/ic_item3.svg'),
                height: 27,
                width: 27,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: context.tokens.spacing.vsdslSpacingMd.left),
                child: AutoSizeText(
                  S.of(context).v3_instruction3,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                    color: context.tokens.color.vsdslColorSurface600,
                    letterSpacing: -0.48,
                    height: 1.3,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: context.tokens.spacing.vsdslSpacingMd.left),
                child: ValueListenableBuilder<int>(
                  valueListenable: channelProvider.countDownProgress,
                  builder: (_, progress, __) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: SizedBox(
                        width: 27,
                        height: 27,
                        child: CircularProgressIndicator(
                          value: progress / channelProvider.maxCountDown,
                          strokeWidth: 4,
                          backgroundColor: const Color(0xFFE9EAF0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF636D8A)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.vsdslSpacingXl.top),
          Padding(
            padding: widget.isQuickConnect
                ? EdgeInsets.zero
                : const EdgeInsets.only(left: 35),
            child: ValueListenableBuilder<int>(
              valueListenable: channelProvider.otp,
              builder: (_, otp, __) {
                return AutoSizeText(
                  otp.toString(),
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w700,
                    color: context.tokens.color.vsdslColorSurface700,
                    letterSpacing: 5.76,
                    height: 1.3,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  String _getDisplayCodeVisualIdentity(String displayCode) {
    String result = displayCode;
    if (displayCode.length > 5) {
      // https://stackoverflow.com/a/56845471/13160681
      result = displayCode
          .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
          .trimRight();
    }
    return result;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initConnectivity() async {
    Connectivity().onConnectivityChanged.listen((result) async {
      setState(() {
        _lastConnectivityResult = result;
      });
    });
  }

  Future<bool> checkInternetConnection() async {
    if (_lastConnectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Try pinging a public internet address
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Connect to Internet
      }
    } on SocketException catch (_) {
      return false; // Only connect to Intranet
    }

    return false;
  }

  TextSpan _buildTextSpan(
      {required String fullText,
      required List<String> formatTexts,
      required TextStyle formatStyle}) {
    List<TextSpan> spans = [];
    int start = 0;

    // Process text based on each substring that needs to be formatted
    while (start < fullText.length) {
      int closestBoldStart = -1;
      String? closestBoldText;

      // Find the earliest occurrence of format text
      for (String boldText in formatTexts) {
        int index = fullText.indexOf(boldText, start);
        if (index != -1 &&
            (closestBoldStart == -1 || index < closestBoldStart)) {
          closestBoldStart = index;
          closestBoldText = boldText;
        }
      }

      // If there is no more format text, add the remaining text
      if (closestBoldStart == -1) {
        spans.add(TextSpan(
          text: fullText.substring(start),
        ));
        break;
      }

      // Add the normal part before the format text
      if (closestBoldStart > start) {
        spans.add(TextSpan(
          text: fullText.substring(start, closestBoldStart),
        ));
      }

      // Add format text
      spans.add(TextSpan(
        text: closestBoldText,
        style: formatStyle,
      ));

      // Update the start position
      start = closestBoldStart + closestBoldText!.length;
    }
    return TextSpan(children: spans);
  }
}
