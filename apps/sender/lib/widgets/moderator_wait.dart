
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:provider/provider.dart';

class ModeratorWait extends StatelessWidget {
  const ModeratorWait({super.key});

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider = Provider.of<PresentStateProvider>(context);
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child:Container(
            padding: const EdgeInsets.fromLTRB(0, 40, 30, 0),
            child: ElevatedButton.icon(
              onPressed: () {
                presentStateProvider.presentEnd();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.black,
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                side: const BorderSide(
                    color: Colors.red,
                    width: 1,
                    style: BorderStyle.solid
                ),
              ),
              icon: const Image(image: Svg('assets/images/ic_exit.svg')),
              label: const Text(
                'EXIT',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            S.of(context).moderator_wait,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
