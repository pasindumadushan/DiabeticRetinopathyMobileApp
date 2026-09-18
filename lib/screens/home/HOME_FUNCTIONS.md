# Home Page Functions

## Overview
The home page serves as the central hub for RetinaInsight, providing quick access to recent patient scans, detailed model architecture information, and step-by-step usage guidance. It combines visual feedback with educational content to help users understand both the app's capabilities and the underlying AI methodology.

## Key Components

### 1. Recent Scans Carousel
- **Purpose**: Displays the 10 most recent patient screening records in a horizontal scroll view
- **Features**:
  - Thumbnail preview from the first saved retinal image
  - Patient name and severity badge (color-coded by DR grade)
  - Tap-to-view integration — opens the full result screen instantly
  - Empty state message when no records exist yet
  - "View all" link jumps to the History tab

### 2. Model Information Section
- **AI Model Overview**:
  - EfficientNet-Lite: Large teacher network used during training to establish accurate diabetic retinopathy detection patterns from retinal fundus images
  - MobileNet: Lightweight student architecture that runs on-device for real-time inference without internet
  - Knowledge Distillation: Trains MobileNet to replicate EfficientNet-Lite predictions, maintaining accuracy at smaller model size
  - Quantization: Converts weights to lower precision, reducing model footprint for faster on-device computation
  - Pruning: Removes redundant network connections, further optimizing size with minimal accuracy trade-off

### 3. How to Use Guide
- **Step-by-step instructions**:
  1. Enter patient details in Retinal Scan tab
  2. Capture or upload up to 4 clear retinal images
  3. Tap Analyze for on-device model inference
  4. Review severity grade and attention heatmap
  5. Confirm diagnosis with ophthalmologist

---

## Research Note (80 words)

The home dashboard integrates a mobile-optimized diabetic retinopathy screening system using knowledge-distilled MobileNet inference. The architecture combines a lightweight teacher-student learning paradigm with quantization and pruning techniques, reducing model size to 5–8 MB while maintaining clinical-grade accuracy. On-device inference eliminates cloud dependency and ensures HIPAA-compliant data privacy. The carousel surfaces recent analyses for quick patient history access, while the model-info section educates users on optimization trade-offs: computational efficiency versus diagnostic precision in resource-constrained mobile environments.
