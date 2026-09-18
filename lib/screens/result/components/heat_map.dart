import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'heatmap_preview.dart';

class HeatMap extends StatefulWidget {
  const HeatMap({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<HeatMap> createState() => _HeatMapState();
}

class _HeatMapState extends State<HeatMap> {
  late List<List<double>> heatmapData;

  @override
  void initState() {
    super.initState();
    heatmapData = _generateHeatmapData();
  }

  List<List<double>> _generateHeatmapData() {
    // Generate synthetic heatmap data (16x16 grid)
    // This simulates model attention areas
    const int gridSize = 16;
    final data = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) {
        // Create attention zones with Gaussian-like distribution
        final centerI = gridSize / 2;
        final centerJ = gridSize / 2;
        
        // Multiple attention centers for realism
        double value = 0.0;
        
        // Center attention
        final distCenter = math.sqrt(
          math.pow(i - centerI, 2) + math.pow(j - centerJ, 2),
        );
        value += math.exp(-distCenter / 3.0);

        // Secondary attention spots (retinal lesion areas)
        final dist1 = math.sqrt(
          math.pow(i - 5, 2) + math.pow(j - 5, 2),
        );
        value += 0.6 * math.exp(-dist1 / 2.5);

        final dist2 = math.sqrt(
          math.pow(i - 12, 2) + math.pow(j - 11, 2),
        );
        value += 0.5 * math.exp(-dist2 / 2.0);
        
        return value.clamp(0.0, 1.0);
      }),
    );
    return data;
  }

  void _showHeatmapPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HeatmapPreview(
          imagePath: widget.imagePath,
          heatmapData: heatmapData,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showHeatmapPreview,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.grid_on_rounded,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attention Map',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'First Image Analysis',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF6B7280).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.touch_app_rounded,
                  color: Colors.grey.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      File(widget.imagePath),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.broken_image,
                            color: Color(0xFF6B7280),
                            size: 48,
                          ),
                        );
                      },
                    ),
                    CustomPaint(
                      painter: _HeatmapOverlayPainter(heatmapData),
                      size: const Size(double.infinity, 250),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: Color(0xFFD97706), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tap to view full heatmap',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF78350F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Red indicates high model attention',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapOverlayPainter extends CustomPainter {
  final List<List<double>> heatmapData;

  _HeatmapOverlayPainter(this.heatmapData);

  Color _getHeatmapColor(double value) {
    final normalized = value.clamp(0.0, 1.0);

    if (normalized < 0.25) {
      final t = normalized / 0.25;
      return Color.lerp(Colors.blue, Colors.green, t)!;
    } else if (normalized < 0.5) {
      final t = (normalized - 0.25) / 0.25;
      return Color.lerp(Colors.green, Colors.yellow, t)!;
    } else if (normalized < 0.75) {
      final t = (normalized - 0.5) / 0.25;
      return Color.lerp(Colors.yellow, Colors.orange, t)!;
    } else {
      final t = (normalized - 0.75) / 0.25;
      return Color.lerp(Colors.orange, Colors.red, t)!;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (heatmapData.isEmpty) return;

    final rows = heatmapData.length;
    final cols = heatmapData[0].length;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    // Paint each cell into an off-screen layer first, then blur the whole
    // layer. This melts the hard grid-cell edges into a smooth radial
    // gradient instead of a blocky checkerboard, and makes the classic
    // "cold -> hot" transition actually readable.
    final blurSigma = math.max(cellWidth, cellHeight) * 0.75;
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
    );

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final value = heatmapData[i][j].clamp(0.0, 1.0);
        if (value < 0.05) continue; // keep cold areas transparent

        final color = _getHeatmapColor(value);
        // Scale opacity with intensity so hot spots pop and cold areas
        // fade into the underlying image, instead of a flat wash of color.
        final opacity = 0.15 + value * 0.55;

        final rect = Rect.fromLTWH(
          j * cellWidth,
          i * cellHeight,
          cellWidth,
          cellHeight,
        );

        canvas.drawRect(rect, Paint()..color = color.withOpacity(opacity));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeatmapOverlayPainter oldDelegate) {
    return oldDelegate.heatmapData != heatmapData;
  }
}
