import 'package:flutter/material.dart';

class ProjectOverview extends StatelessWidget {
  const ProjectOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Objective',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This initiative builds an accessible mobile app that uses optimized deep '
                  'learning to automatically detect diabetic retinopathy (DR). The goal is a '
                  'resource-efficient, high-performing model developed through a deductive '
                  'approach, a design-oriented methodology, and a quantitative research design.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Publicly available retinal fundus image datasets are used, with additional '
                  'pre-processing, labelling, and stratification by severity level. Baseline '
                  'convolutional neural network (CNN) models are then optimized and benchmarked '
                  'for efficiency using quantization, fine-tuning, pruning, and knowledge '
                  'distillation.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'The optimized model is integrated into this app using on-device frameworks '
                  'like TensorFlow Lite, enabling fully offline diagnosis with accurate, '
                  'interpretable outputs suited for real-world use — while addressing '
                  'diagnostic accuracy, interpretability, trustworthiness, and imbalanced '
                  'training data.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
