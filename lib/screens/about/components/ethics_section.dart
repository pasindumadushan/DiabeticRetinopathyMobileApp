import 'package:flutter/material.dart';

class EthicsSection extends StatelessWidget {
  const EthicsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ethical Considerations',
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
              children: [
                _EthicsRow(
                  icon: Icons.shield_outlined,
                  text: 'Designed with GDPR and HIPAA compliance in mind for handling patient health data.',
                ),
                SizedBox(height: 14),
                _EthicsRow(
                  icon: Icons.lock_outline_rounded,
                  text: 'Patient records and images are stored locally on-device, keeping data private by default.',
                ),
                SizedBox(height: 14),
                _EthicsRow(
                  icon: Icons.visibility_outlined,
                  text: 'Interpretable outputs — such as attention heatmaps — support clinical trust in each prediction.',
                ),
                SizedBox(height: 14),
                _EthicsRow(
                  icon: Icons.balance_outlined,
                  text: 'Class imbalance in DR severity data is addressed to avoid biased or misleading predictions.',
                ),
                SizedBox(height: 14),
                _EthicsRow(
                  icon: Icons.medical_information_outlined,
                  text: 'Results are intended as a screening aid, not a replacement for professional diagnosis.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EthicsRow extends StatelessWidget {
  const _EthicsRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
