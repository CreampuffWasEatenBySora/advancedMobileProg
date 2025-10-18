import 'dart:async';

import 'package:firebase_nexus/appColors.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // Delay for 3 seconds then navigate to HomeScreen
    Timer(const Duration(seconds: 1), () {
      Navigator.pushNamed(context, '/tioWelcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        color: AppColors.primaryVariant,
        child: const SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Express-O',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      )),
    );
  }
}
