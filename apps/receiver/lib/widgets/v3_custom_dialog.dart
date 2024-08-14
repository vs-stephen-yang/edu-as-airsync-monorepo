import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class V3CustomDialog extends StatelessWidget {
  const V3CustomDialog(
      {super.key,
      required this.alignmentGeometry,
      required this.title,
      required this.content,
      required this.item1,
      required this.item2,
      required this.onItem1,
      required this.onItem2});

  final AlignmentGeometry alignmentGeometry;
  final String title, content;
  final String item1, item2;
  final VoidCallback onItem1, onItem2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 258,
          right: 134,
          child: UnconstrainedBox(
            // Use UnconstrainedBox to override Dialog minimum size
            // https://blog.csdn.net/shving/article/details/114485776
            constrainedAxis: Axis.vertical,
            child: SizedBox(
              width: 253,
              height: 192,
              child: Dialog(
                insetPadding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                child: Stack(
                  children: [
                    Positioned(
                      left: 13,
                      top: 27,
                      right: 13,
                      child: AutoSizeText(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 13,
                      top: 61,
                      right: 13,
                      child: AutoSizeText(
                        content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 15,
                      top: 132,
                      right: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 108,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: const Color(0xFF3C5AAA),
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF3C5AAA),
                                  width: 1.5,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: onItem1,
                              child: AutoSizeText(item1),
                            ),
                          ),
                          SizedBox(
                            width: 108,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF3C5AAA),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: onItem2,
                              child: AutoSizeText(item2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
