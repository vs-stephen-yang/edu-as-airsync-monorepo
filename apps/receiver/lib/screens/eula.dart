import 'package:flutter/material.dart';

class Eula extends StatefulWidget {
  const Eula({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EulaState();
}

class EulaState extends State<Eula> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Eula',
              style: TextStyle(color: Colors.blue, fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
