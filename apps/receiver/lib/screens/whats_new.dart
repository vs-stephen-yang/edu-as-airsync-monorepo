import 'package:display_flutter/app_colors.dart';
import 'package:display_flutter/generated/l10n.dart';
import 'package:display_flutter/model/control_socket.dart';
import 'package:display_flutter/widgets/stream_function.dart';
import 'package:flutter/material.dart';

class WhatsNew extends StatefulWidget {
  const WhatsNew({Key? key}) : super(key: key);

  @override
  _WhatsNewState createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: ControlSocket().isPresenting()
            ? AppColors.primary_grey_tran
            : AppColors.primary_grey,
      ),
      child: Column(
        children: [
          Container(
            // alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.06,
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: Colors.transparent,
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.primary_white),
                    onPressed: () {
                      StreamFunction.showWhatsNew.value = false;
                    },
                  ),
                ),
                Expanded(
                    child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Text(
                      S.of(context).main_whats_new_title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary_white),
                    ),
                  ),
                )),
              ],
            ),
          ),
          const RawScrollbar(
            isAlwaysShown: true,
            thumbColor: AppColors.primary_white,
            child: SingleChildScrollView(
              child: Text(
                "",
                style: TextStyle(color: AppColors.primary_white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
