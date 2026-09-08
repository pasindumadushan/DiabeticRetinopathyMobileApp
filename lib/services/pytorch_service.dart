import 'dart:async';

import 'package:flutter/services.dart';

class PyTorchService {
  PyTorchService._();

  static final PyTorchService instance = PyTorchService._();

  static const MethodChannel _channel = MethodChannel('pytorch_inference');
  static bool _channelReady = false;

  Future<String> analyzeImages(List<String> imagePaths, [String outputDir = ""]) async {
    if (!_channelReady) {
      _channelReady = true;
    }

    try {
      final result = await _channel.invokeMethod<String>(
        'analyzeImages',
        {'imagePaths': imagePaths, 'outputDir': outputDir},
      );
      return result ?? 'No result returned from native inference.';
    } on PlatformException catch (e) {
      return e.message ?? 'Native inference failed.';
    }
  }
}
