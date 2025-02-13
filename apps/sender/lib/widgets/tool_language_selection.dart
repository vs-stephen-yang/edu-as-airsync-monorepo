import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/pref_language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  @override
  Widget build(BuildContext context) {
    PrefLanguageProvider provider = Provider.of<PrefLanguageProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: const Color.fromRGBO(0x4E, 0x4E, 0x4E, 1.0),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 200,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: IconButton(
                        onPressed: () {
                        },
                        splashRadius: 20,
                        focusColor: Colors.grey,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            S.of(context).main_language,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.localeMap.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: (provider.language ==
                                provider.localeMap.keys.elementAt(index))
                            ? Colors.blue
                            : Colors.grey,
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                      onPressed: () {
                        provider.setLanguage(
                            provider.localeMap.keys.elementAt(index));
                      },
                      child: Text(
                        provider.localeMap.keys.elementAt(index),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 5, color: Colors.transparent);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
