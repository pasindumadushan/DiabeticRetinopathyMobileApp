import 'package:flutter/material.dart';
import '../../models/analysis_result.dart';
import 'components/result_header.dart';
import 'components/ben_graham_enhance.dart';
import 'components/heat_map.dart';
import 'components/model_suggestion.dart';
import 'components/footer_buttons.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
  });

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analysis Results',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            ResultHeader(result: result),
            const SizedBox(height: 16),
            if (result.benGrahamPaths.isNotEmpty)
              BenGrahamEnhance(benGrahamPaths: result.benGrahamPaths),
            const SizedBox(height: 16),
            if (result.imagePaths.isNotEmpty)
              HeatMap(imagePath: result.imagePaths.first),
            const SizedBox(height: 16),
            ModelSuggestion(result: result),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: FooterButtons(
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
