# Result Page Functions

## Overview
The result page presents the complete diagnostic output after model inference, combining quantitative predictions with interpretable visual explanations and clinical recommendations. It displays severity classification with color-coded gradients, AI attention heatmaps for transparency, Ben Graham-enhanced image previews, and severity-specific clinical guidance—enabling clinicians to validate machine predictions and make informed treatment decisions with full diagnostic context.

## Key Components

### 1. Result Header
- **Severity Badge**:
  - Color gradient tied to DR grade (green No DR → brown Proliferative)
  - Displays predicted class (0–4) and severity label
  - Shows mean prediction confidence score
  - Real-time icon matching severity level
- **Patient Summary**: Name, age, gender, diabetic status visible in header context
- **Visual Hierarchy**: Gradient background emphasizes urgency based on severity

### 2. Ben Graham Enhanced Images
- **Carousel Display**:
  - Horizontal scroll through all preprocessed images
  - Thumbnail view with shadow effects
  - Tap-to-view full-screen preview
  - Fallback placeholder for missing/corrupted images
- **Purpose**: Shows preprocessing results; helps clinicians assess image quality and vascular enhancement

### 3. Attention Heatmap (Model Interpretability)
- **Overlay Visualization**:
  - Blurred grid overlay on original retinal image
  - Color gradient: blue (low attention) → red (high attention)
  - Gaussian smoothing eliminates hard grid edges for readable gradient
  - Intensity-scaled opacity (cold areas fade, hot spots pop)
- **Clinical Value**: Reveals which retinal regions drove severity prediction, supporting trust in AI decision
- **Full-screen Mode**: Tap heatmap to open dedicated preview with legend

### 4. Model Recommendation Card
- **Severity-Specific Guidance**:
  - No DR: "Continue regular eye check-ups"
  - Mild: "Monitor closely and consult ophthalmologist"
  - Moderate: "Urgent ophthalmology consultation recommended"
  - Severe: "Immediate specialist consultation required"
  - Proliferative: "Urgent treatment required to prevent vision loss"
- **Visual Styling**: Background color and border match severity level for quick scanning
- **Disclaimer**: Emphasizes result is a screening aid, not a diagnosis replacement

### 5. Result Navigation
- **Data Sources**:
  - Fresh analysis: Fetched from `AnalysisResult` object passed from upload
  - History replay: Reconstructed from `patient_records` row + saved images/severity
- **Back Navigation**: Close button returns to previous screen (upload or history)
- **State Preservation**: No additional DB writes on result view—read-only display mode

### 6. Image Gallery Integration
- **Original Images**: Displayed in heatmap for context
- **Ben Graham Variants**: Separate carousel for preprocessing comparison
- **File Management**: Images loaded from patient folder, handled gracefully if missing

---

## Research Note (80 words)

The result display implements explainable AI for clinical validation: severity prediction (5-class DR taxonomy) is color-mapped to urgency gradients; attention heatmaps via blurred overlays reveal model focus regions without hard artifacts; intensity-scaled opacity prevents cold-area washout. Severity-stratified recommendations align with clinical guidelines. Images sourced from either live analysis (AnalysisResult object) or history replay (SQLite + disk recovery), ensuring consistent UX across both pathways. The read-only architecture prevents accidental data mutation, supporting audit trails and compliance with HIPAA record immutability requirements in clinical workflows.
