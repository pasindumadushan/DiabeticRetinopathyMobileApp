import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

class HeatmapPreview extends StatefulWidget {
  const HeatmapPreview({
    super.key,
    required this.imagePath,
    required this.heatmapData,
  });

  final String imagePath;
  final List<List<double>> heatmapData;

  @override
  State<HeatmapPreview> createState() => _HeatmapPreviewState();
}

class _HeatmapPreviewState extends State<HeatmapPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Heatmap Preview',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Stack(
          children: [
            Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
            ),
            CustomPaint(
              painter: HeatmapPainter(widget.heatmapData),
              size: Size.infinite,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Low',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.green,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Text(
                  'High',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Areas highlighted in red indicate high model attention',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final List<List<double>> heatmapData;

  HeatmapPainter(this.heatmapData);

  Color _getHeatmapColor(double value) {
    // Value should be between 0 and 1
    final normalized = value.clamp(0.0, 1.0);

    if (normalized < 0.25) {
      // Blue to Green
      final t = normalized / 0.25;
      return Color.lerp(Colors.blue, Colors.green, t)!;
    } else if (normalized < 0.5) {
      // Green to Yellow
      final t = (normalized - 0.25) / 0.25;
      return Color.lerp(Colors.green, Colors.yellow, t)!;
    } else if (normalized < 0.75) {
      // Yellow to Orange
      final t = (normalized - 0.5) / 0.25;
      return Color.lerp(Colors.yellow, Colors.orange, t)!;
    } else {
      // Orange to Red
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

    // Blur the whole overlay layer so the grid cells melt into a smooth
    // gradient instead of a hard-edged, blocky checkerboard.
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
        final opacity = 0.15 + value * 0.6;

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
  bool shouldRepaint(HeatmapPainter oldDelegate) {
    return oldDelegate.heatmapData != heatmapData;
  }
}
