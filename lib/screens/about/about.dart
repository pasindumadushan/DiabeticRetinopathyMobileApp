import 'package:flutter/material.dart';

import 'components/about_header.dart';
import 'components/developer_card.dart';
import 'components/ethics_section.dart';
import 'components/methodology_section.dart';
import 'components/project_overview.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AboutHeader(),
              SizedBox(height: 24),
              ProjectOverview(),
              SizedBox(height: 24),
              MethodologySection(),
              SizedBox(height: 24),
              EthicsSection(),
              SizedBox(height: 24),
              DeveloperCard(),
            ],
          ),
        ),
      ),
    );
  }
}
