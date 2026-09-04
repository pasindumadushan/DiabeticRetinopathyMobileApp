import 'package:flutter/material.dart';
import 'components/upload_header.dart';
import 'components/selection_button.dart';
import 'components/selected_images.dart';
import 'components/footer_buttons.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

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
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              UploadHeader(),
              SizedBox(height: 20),
              SelectionButton(),
              SizedBox(height: 16),
              SelectedImages(),
              SizedBox(height: 20),
              FooterButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
