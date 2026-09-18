import 'package:flutter/material.dart';

import '../../services/database_helper.dart';
import 'components/home_header.dart';
import 'components/model_info_section.dart';
import 'components/recent_scans_carousel.dart';
import 'components/start_new_screening.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = DatabaseHelper.instance.fetchPatientRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 24),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _recordsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final records = snapshot.data ?? const [];
                  return RecentScansCarousel(
                    records: records.take(10).toList(),
                    onViewAll: () => DefaultTabController.of(context).animateTo(2),
                  );
                },
              ),
              const SizedBox(height: 24),
              const ModelInfoSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const StartNewScreeningButton(),
    );
  }
}
