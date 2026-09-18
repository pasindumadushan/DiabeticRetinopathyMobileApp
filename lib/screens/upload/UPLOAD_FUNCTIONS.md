# Upload Page Functions

## Overview
The upload page is the primary screening interface where users enter patient demographics, capture or upload retinal fundus images, and trigger the on-device deep learning model for automated diabetic retinopathy detection. It orchestrates data collection, image preprocessing via Ben Graham enhancement, database persistence, and seamless navigation to analysis results with real-time severity classification.

## Key Components

### 1. Patient Information Input
- **Fields Collected**:
  - Patient name (text validation)
  - Age (numeric input)
  - Gender dropdown (Male/Female)
  - Diabetic status (Yes/No)
  - Diabetes duration in years (decimal input)
  - Email address (optional)
- **Validation**: Form validation ensures all required fields are populated before analysis

### 2. Image Selection & Capture
- **Multi-image support**: Users can select up to 4 retinal images
- **Sources**: Camera capture or gallery upload
- **Image Management**:
  - Real-time preview thumbnails
  - Remove individual images before analysis
  - Quality enforcement (80% JPEG quality)
  - Max 4 images enforced with user feedback

### 3. Image Storage & Organization
- **Local Storage**:
  - Creates patient-specific folder: `patient_record_<id>/`
  - Copies images from gallery/camera to app documents directory
  - Generates timestamped filenames to prevent conflicts
  - Stores image paths in SQLite `image_paths` column

### 4. Analysis Engine
- **PyTorch Service Integration**:
  - Invokes native Android/iOS inference via method channel
  - Passes image paths and output directory to model
  - Receives severity class (0–4: No DR to Proliferative) and mean confidence
  - Parses model output via regex extraction

### 5. Ben Graham Enhancement
- **Preprocessing**: Native layer applies contrast-limited adaptive histogram equalization
- **Output**: Saves enhanced images to patient folder with `ben_graham` filename marker
- **Purpose**: Improves retinal vessel visibility for diagnostic interpretation

### 6. Severity Persistence & Navigation
- **Database Save**:
  - Stores computed severity label in `patient_records.severity` column
  - Creates `AnalysisResult` object with all patient/image/model data
  - Persists results for history carousel access
- **Navigation**: Navigates to `ResultScreen` displaying severity badge, attention heatmap, and clinical recommendation

---

## Research Note (80 words)

The upload workflow implements end-to-end image-to-diagnosis pipeline: patient stratification via demographics, multi-image acquisition with 4-frame redundancy for robustness, local preprocessing via Ben Graham enhancement for vessel contrast, on-device PyTorch inference for real-time classification into 5 DR severity grades, and deterministic result persistence. SQLite storage of image paths and severity enables offline-first operation and audit trails. Regex-based model output parsing extracts predicted class and confidence scores. The modular design decouples image capture, preprocessing, inference, and result storage—supporting future model swaps or ensemble methods without workflow disruption.
