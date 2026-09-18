# History Page Functions

## Overview
The history page provides persistent access to all completed patient screenings via SQLite database retrieval and display. It surfaces saved records chronologically, enabling clinicians to review past analyses, track patient progress across multiple visits, and instantly replay any previous diagnosis by reconstructing the result screen from stored images and severity classifications without re-running inference.

## Key Components

### 1. Database Fetching
- **SQLite Query**:
  - Retrieves all `patient_records` rows ordered by `created_at DESC` (newest first)
  - Runs asynchronously via `DatabaseHelper.fetchPatientRecords()`
  - Shows loading spinner while query executes
  - Handles errors gracefully with error message display

### 2. Patient Record List Display
- **Card Layout**:
  - Patient name with person icon
  - Age, gender, diabetic status rows
  - **Severity Badge** — color-coded label (persisted from analysis)
  - Chevron affordance indicating tappability
  - Shadow/rounded corners matching app design system
- **Empty State**: Shows message when no records exist, encouraging new screening

### 3. Record Selection & Navigation
- **Tap-to-Replay**:
  - Reconstructs `AnalysisResult` from saved `patient_records` row
  - Reads image paths from `image_paths` column (comma-separated)
  - Scans patient folder for Ben Graham enhanced images
  - Fetches severity from `severity` SQLite column → maps back to predicted class
  - Navigates to `ResultScreen` with reconstructed analysis (no re-inference needed)
- **Shared Utility**: Uses `openRecordResult()` from `patient_record_utils.dart`

### 4. Data Integrity & Consistency
- **Image Recovery**: Gracefully handles missing/deleted image files (shows placeholder)
- **Severity Mapping**: `AnalysisResult.classFromSeverityLabel()` reverses severity strings to class codes
- **Timestamp Preservation**: `created_at` visible in query; enables audit trails

### 5. View All Integration
- **Home Screen Link**: "View all" button in home carousel jumps to History tab
- **Cross-Screen Navigation**: Seamless UX between recent scans (home) and full history

---

## Research Note (50 words)

History retrieval implements offline-first record replay: SQLite queries fetch all screenings sorted by timestamp; tapped records reconstruct AnalysisResult from persisted images and severity labels via deterministic reversal mapping. No re-inference occurs—only UI reconstruction. This design enables HIPAA-compliant audit trails, low-latency access to past diagnoses, and longitudinal patient tracking for chronic disease monitoring.
