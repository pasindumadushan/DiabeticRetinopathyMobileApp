import 'package:flutter/material.dart';

import 'components/appearance_section.dart';
import 'components/settings_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SettingsHeader(),
              SizedBox(height: 24),
              AppearanceSection(),
            ],
          ),
        ),
      ),
    );
  }
}
