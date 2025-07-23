import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/assets/tokens/tokens.g.dart';
import 'package:display_flutter/providers/multi_window_provider.dart';
import 'package:display_flutter/widgets/v3_instruction.dart';
import 'package:display_flutter/widgets/v3_main_connection_info.dart';
import 'package:display_flutter/widgets/v3_main_instruction_section.dart';
import 'package:display_flutter/widgets/v3_main_qr_code_area.dart';
import 'package:display_flutter/widgets/v3_participants_view.dart';
import 'package:display_flutter/widgets/v3_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class V3MainInfoLandscape extends StatelessWidget {
  const V3MainInfoLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiWindowAdaptiveLayout(
      landscape: Row(
        children: [
          Expanded(
            flex: 5,
            child: const V3MainConnectionInfo(),
          ),
          Container(
            width: 1,
            color: context.tokens.color.vsdslColorOutline,
          ),
          Expanded(
            flex: 2,
            child: const V3ParticipantsView(),
          ),
        ],
      ),
      landscapeThirds: V3MainConnectionInfo(),
      landscapeHalf: V3MainConnectionInfo(),
      landscapeOneThird: V3MainConnectionInfoOneThird(),
    );
  }
}

class V3MainConnectionInfoOneThird extends StatefulWidget {
  const V3MainConnectionInfoOneThird({super.key});

  @override
  State<V3MainConnectionInfoOneThird> createState() =>
      _V3MainConnectionInfoOneThirdState();
}

class _V3MainConnectionInfoOneThirdState
    extends State<V3MainConnectionInfoOneThird> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppPreferences().textSizeOptionNotifier,
      builder: (context, value, child) {
        return Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(
                  left: 13.3,
                  right: 13.3,
                  top: 13.3,
                  bottom: 10,
                ),
                child: V3Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        const V3Instruction(isCastToDevice: false),
                        const V3MainQrCodeArea(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const V3MainInstructionSection(),
            const Gap(30.0),
          ],
        );
      },
    );
  }
}
