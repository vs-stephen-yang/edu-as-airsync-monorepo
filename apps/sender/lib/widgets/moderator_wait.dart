
import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModeratorWait extends StatelessWidget {
  const ModeratorWait({super.key});

  @override
  Widget build(BuildContext context) {
    PresentStateProvider presentStateProvider = Provider.of<PresentStateProvider>(context);
    return SizedBox(
      width: 300,
      height: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.groups,
                        color: Colors.white,
                      ))),
              Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  'Moderator',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Spacer(flex: 1,),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Divider(color: Colors.white12,),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Text(
              S.of(context).moderator_wait,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: ElevatedButton(
              onPressed: () {
                presentStateProvider.presentEnd();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red,
                fixedSize: const Size(300, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              // icon: const Image(image: Svg('assets/images/ic_exit.svg')),
              child: const Text(
                'EXIT',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
