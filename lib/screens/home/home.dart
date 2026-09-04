import 'package:flutter/material.dart';
import 'components/home_header.dart';
import 'components/start_new_screening.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            children: [
              HomeHeader(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StartNewScreeningButton(),
    );
  }
}
