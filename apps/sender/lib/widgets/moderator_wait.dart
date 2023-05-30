
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:flutter/material.dart';

class ModeratorWait extends StatelessWidget {
  const ModeratorWait({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      S.of(context).moderator_wait,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 20,
      ),
    );
  }
}
