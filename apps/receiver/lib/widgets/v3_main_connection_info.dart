import 'package:display_flutter/app_preferences.dart';
import 'package:display_flutter/widgets/v3_main_instruction_area.dart';
import 'package:display_flutter/widgets/v3_main_instruction_section.dart';
import 'package:display_flutter/widgets/v3_main_qr_code_area.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class V3MainConnectionInfo extends StatefulWidget {
  const V3MainConnectionInfo({super.key});

  @override
  State<V3MainConnectionInfo> createState() => _V3MainConnectionInfoState();
}

class _V3MainConnectionInfoState extends State<V3MainConnectionInfo> {
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
              child: _buildMainContent(),
            ),
            const V3MainInstructionSection(),
            const Gap(30.0),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Row(
      children: [
        Expanded(
          child: V3MainInstructionArea(
            scrollController: _scrollController,
          ),
        ),
        const V3MainQrCodeArea(),
      ],
    );
  }
}
