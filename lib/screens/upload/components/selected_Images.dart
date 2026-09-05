import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class SelectedImages extends StatelessWidget {
  const SelectedImages({
    super.key,
    required this.imagePaths,
    required this.onRemove,
  });

  final List<String> imagePaths;
  final void Function(String path) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          if (imagePaths.isEmpty)
            const Text(
              'No images selected yet',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: imagePaths.map((path) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          p.basename(path),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onRemove(path),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
