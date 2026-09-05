import 'package:flutter/material.dart';

class InputFields extends StatelessWidget {
  const InputFields({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.genderValue,
    required this.diabeticValue,
    required this.durationController,
    required this.emailController,
    required this.onGenderChanged,
    required this.onDiabeticChanged,
  });

  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController durationController;
  final TextEditingController emailController;
  final String genderValue;
  final String diabeticValue;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onDiabeticChanged;

  @override
  Widget build(BuildContext context) {
    final fields = [
      _FieldConfig(
        label: 'Patient Name',
        required: true,
        hint: 'Enter patient name',
        controller: nameController,
      ),
      _FieldConfig(
        label: 'Age',
        required: true,
        hint: 'Enter age',
        keyboardType: TextInputType.number,
        controller: ageController,
      ),
      _FieldConfig(
        label: 'Gender',
        required: true,
        hint: 'Male',
        isDropdown: true,
        dropdownValue: genderValue,
        options: const ['Male', 'Female', 'Other'],
        onChanged: onGenderChanged,
      ),
      _FieldConfig(
        label: 'Diabetic',
        required: false,
        hint: 'Yes',
        isDropdown: true,
        dropdownValue: diabeticValue,
        options: const ['Yes', 'No'],
        onChanged: onDiabeticChanged,
      ),
      _FieldConfig(
        label: 'Duration of Diabetes (Years)',
        required: false,
        hint: 'Enter years',
        keyboardType: TextInputType.number,
        controller: durationController,
      ),
      _FieldConfig(
        label: 'Email',
        required: false,
        hint: 'Enter email address',
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
      ),
    ];

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ...fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: field.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                      children: field.required
                          ? const [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  field.isDropdown
                      ? DropdownButtonFormField<String>(
                          initialValue: field.dropdownValue ?? field.options.first,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: field.options
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ),
                              )
                              .toList(),
                          onChanged: field.onChanged,
                          validator: (value) {
                            if (field.required && (value == null || value.isEmpty)) {
                              return 'Please select ${field.label.toLowerCase()}';
                            }
                            return null;
                          },
                        )
                      : TextFormField(
                          controller: field.controller,
                          keyboardType: field.keyboardType,
                          validator: (value) {
                            if (field.required && (value == null || value.trim().isEmpty)) {
                              return 'Please enter ${field.label.toLowerCase()}';
                            }

                            if (field.label == 'Email' &&
                                value != null &&
                                value.trim().isNotEmpty &&
                                !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }

                            if (field.label == 'Age' &&
                                value != null &&
                                value.trim().isNotEmpty &&
                                (int.tryParse(value.trim()) == null || int.parse(value.trim()) < 0)) {
                              return 'Please enter a valid age';
                            }

                            if (field.label == 'Duration of Diabetes (Years)' &&
                                value != null &&
                                value.trim().isNotEmpty &&
                                (double.tryParse(value.trim()) == null || double.parse(value.trim()) < 0)) {
                              return 'Please enter a valid duration';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: field.hint,
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FieldConfig {
  const _FieldConfig({
    required this.label,
    required this.required,
    required this.hint,
    this.keyboardType,
    this.isDropdown = false,
    this.options = const [],
    this.dropdownValue,
    this.controller,
    this.onChanged,
  });

  final String label;
  final bool required;
  final String hint;
  final TextInputType? keyboardType;
  final bool isDropdown;
  final List<String> options;
  final String? dropdownValue;
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;
}
