import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pic_firebase_crud/screen/Firebase_data.dart';

class splachscreen extends StatefulWidget {
  const splachscreen({super.key});

  @override
  State<splachscreen> createState() => _splachscreenState();
}

class _splachscreenState extends State<splachscreen> {
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Firebasecrud()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Center(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(
                "assets/images/logo.png",
              ),
              radius: 60,
            ),
          ),
        ],
      ),
    );
  }
}
