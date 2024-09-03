import 'package:flutter/material.dart';
import 'package:pic_firebase_crud/routes/Route.dart';
import 'package:pic_firebase_crud/screen/Firebase_data.dart';
import 'package:pic_firebase_crud/screen/splachscreen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case RouteName.splachscreen:
        return MaterialPageRoute(
          builder: (context) => const splachscreen(),
        );
      case RouteName.Firebasecrud:
        return MaterialPageRoute(builder: (context) => Firebasecrud());
      default:
        return MaterialPageRoute(builder: (context) {
          return const Scaffold(
            body: Center(
              child: Text("No Route Found"),
            ),
          );
        });
    }
  }
}
