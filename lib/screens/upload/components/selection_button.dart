import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectionButton extends StatelessWidget {
  const SelectionButton({
    super.key,
    required this.onSelectImage,
    required this.maxImages,
    required this.selectedCount,
  });

  final Future<void> Function(ImageSource source) onSelectImage;
  final int maxImages;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final isDisabled = selectedCount >= maxImages;

    final items = [
      _SelectionOption(
        icon: Icons.camera_alt_outlined,
        title: 'Camera',
        subtitle: isDisabled ? 'Maximum $maxImages images selected' : 'Take a new retinal photo',
        source: ImageSource.camera,
      ),
      _SelectionOption(
        icon: Icons.photo_library_outlined,
        title: 'Gallery',
        subtitle: isDisabled ? 'Maximum $maxImages images selected' : 'Choose an existing image',
        source: ImageSource.gallery,
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: isDisabled ? null : () async {
              await onSelectImage(items[i].source);
            },
            child: Opacity(
              opacity: isDisabled ? 0.6 : 1,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E9FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(items[i].icon, color: const Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
            ),
          )
        ],
      ],
    );
  }
}

class _SelectionOption {
  const _SelectionOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.source,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ImageSource source;
}
