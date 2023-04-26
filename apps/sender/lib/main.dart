import 'package:display_cast_flutter/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        scaffoldBackgroundColor: Colors.black, // Set app background color
      ),
      initialRoute: "/home",
      navigatorKey: NavigationService.navigationKey,
      routes: {
        // for "navService.popUntil('/home')"
        '/home': (context) => const Home(),
      },
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/home':
            return MaterialPageRoute<String>(
                builder: (context) => const Home());
        }
        return null;
      },
      // home: const Home(),
    );
  }
}
