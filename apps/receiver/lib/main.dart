import 'package:display_flutter/screens/eula.dart';
import 'package:display_flutter/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // hide the Android Status Bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/main_page',
      navigatorKey: NavigationService.navigationKey,
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/eula':
            return MaterialPageRoute<String>(
                builder: (context) => const Eula());
          case '/main_page':
            return MaterialPageRoute<String>(
                builder: (context) => const MainPage());
        }
      },
      home: const MainPage(),
    );
  }
}
