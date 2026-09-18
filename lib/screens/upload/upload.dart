import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/analysis_result.dart';
import '../../services/database_helper.dart';
import '../../services/pytorch_service.dart';
import '../result/result.dart';
import 'components/upload_header.dart';
import 'components/input_fields.dart';
import 'components/selection_button.dart';
import 'components/selected_images.dart';
import 'components/footer_buttons.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  static const int _maxImages = 4;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _genderValue = 'Male';
  String _diabeticValue = 'Yes';
  final List<String> _selectedImagePaths = [];

  void _removeImage(String path) {
    setState(() {
      _selectedImagePaths.remove(path);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    if (_selectedImagePaths.length >= _maxImages) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select up to 4 images only.')),
      );
      return;
    }

    if (source == ImageSource.camera) {
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      setState(() {
        if (_selectedImagePaths.length < _maxImages) {
          _selectedImagePaths.add(pickedFile.path);
        }
      });
      return;
    }

    final remainingSlots = _maxImages - _selectedImagePaths.length;
    if (remainingSlots <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select up to 4 images only.')),
      );
      return;
    }

    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isEmpty) return;

    final allowedFiles = pickedFiles.take(remainingSlots).toList();
    setState(() {
      for (final file in allowedFiles) {
        if (file.path.isNotEmpty) {
          _selectedImagePaths.add(file.path);
        }
      }
    });

    if (allowedFiles.length < pickedFiles.length && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only 4 images are allowed.')),
      );
    }
  }

  void _clearFields() {
    setState(() {
      _patientNameController.clear();
      _ageController.clear();
      _durationController.clear();
      _emailController.clear();
      _genderValue = 'Male';
      _diabeticValue = 'Yes';
      _selectedImagePaths.clear();
    });
  }

  void _handleCancel() {
    _clearFields();
  }

  Future<void> _handleAnalyze() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final record = {
      'patient_name': _patientNameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'gender': _genderValue,
      'diabetic': _diabeticValue,
      'diabetes_duration': double.tryParse(_durationController.text.trim()) ?? 0.0,
      'email': _emailController.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
      'image_paths': '',
    };

    final patientId = await DatabaseHelper.instance.insertPatientRecord(record);
    String? savedImagePaths;

    if (_selectedImagePaths.isNotEmpty) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final folder = Directory('${appDocDir.path}/patient_record_$patientId');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final copiedPaths = <String>[];
      for (int index = 0; index < _selectedImagePaths.length; index++) {
        final sourceFile = File(_selectedImagePaths[index]);
        if (!await sourceFile.exists()) {
          continue;
        }

        final extension = sourceFile.path.split('.').last;
        final targetFile = File(
          '${folder.path}/image_${DateTime.now().millisecondsSinceEpoch}_$index.$extension',
        );

        final copiedFile = await sourceFile.copy(targetFile.path);
        copiedPaths.add(copiedFile.path);
      }

      savedImagePaths = copiedPaths.isNotEmpty ? copiedPaths.join(',') : '';
      await DatabaseHelper.instance.updatePatientRecordImagePaths(patientId, savedImagePaths);

      final analysisMessage = await PyTorchService.instance.analyzeImages(
        _selectedImagePaths,
        folder.path,
      );

      if (!mounted) return;

      // Parse the analysis message to extract class and mean
      int predictedClass = 0;
      double meanPrediction = 0.0;
      try {
        final regex = RegExp(r'Mean severity class: (\d+)');
        final match = regex.firstMatch(analysisMessage);
        if (match != null) {
          predictedClass = int.parse(match.group(1)!);
        }
        
        final meanRegex = RegExp(r'mean: ([\d.]+)');
        final meanMatch = meanRegex.firstMatch(analysisMessage);
        if (meanMatch != null) {
          meanPrediction = double.parse(meanMatch.group(1)!);
        }
      } catch (e) {
        debugPrint('Error parsing analysis message: $e');
      }

      // Get ben graham image paths
      final benGrahamFiles = folder.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('ben_graham'))
          .map((file) => file.path)
          .toList();

      if (!mounted) return;

      final result = AnalysisResult(
        predictedClass: predictedClass,
        meanPrediction: meanPrediction,
        imagePaths: copiedPaths,
        benGrahamPaths: benGrahamFiles,
        analysisMessage: analysisMessage,
        patientName: _patientNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _genderValue,
        diabetic: _diabeticValue,
        diabetesDuration: double.tryParse(_durationController.text.trim()) ?? 0.0,
      );

      await DatabaseHelper.instance.updatePatientRecordSeverity(
        patientId,
        result.severityLabel,
      );

      if (!mounted) return;

      _clearFields();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: result),
        ),
      );
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _durationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            DefaultTabController.of(context).animateTo(0);
          },
        ),
        title: const Text(
          'Upload retinal image',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const UploadHeader(),
                const SizedBox(height: 20),
                InputFields(
                  nameController: _patientNameController,
                  ageController: _ageController,
                  durationController: _durationController,
                  emailController: _emailController,
                  genderValue: _genderValue,
                  diabeticValue: _diabeticValue,
                  onGenderChanged: (value) {
                    if (value != null) {
                      setState(() => _genderValue = value);
                    }
                  },
                  onDiabeticChanged: (value) {
                    if (value != null) {
                      setState(() => _diabeticValue = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                SelectionButton(
                  onSelectImage: _pickImage,
                  maxImages: _maxImages,
                  selectedCount: _selectedImagePaths.length,
                ),
                const SizedBox(height: 16),
                SelectedImages(
                  imagePaths: _selectedImagePaths,
                  onRemove: _removeImage,
                ),
                const SizedBox(height: 20),
                FooterButtons(onAnalyze: _handleAnalyze, onCancel: _handleCancel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
