import 'package:flutter/services.dart';

class PyTorchService {
  PyTorchService._();

  static final PyTorchService instance = PyTorchService._();

  static const MethodChannel _channel = MethodChannel('pytorch_inference');

  Future<String> analyzeImages(List<String> imagePaths) async {
    final result = await _channel.invokeMethod<String>(
      'analyzeImages',
      {'imagePaths': imagePaths},
    );
    return result ?? 'No result returned from native inference.';
  }
}
