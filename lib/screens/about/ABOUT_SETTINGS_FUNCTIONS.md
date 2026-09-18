# About & Settings Pages Functions

## Overview
The about page educates users on the project's research methodology, ethical framework, and developer credentials—establishing credibility and transparency in a clinical diagnostic tool. The settings page enables personalization of the app experience through theme preference control, persisted via SharedPreferences. Together, they provide contextual knowledge and user autonomy, essential for medical software trust and accessibility in resource-diverse healthcare settings.

---

## ABOUT PAGE

### 1. Project Overview Section
- **Educational Content**:
  - Summarizes initiative objective (optimized deep learning for DR detection)
  - Explains dataset sourcing (public retinal fundus images)
  - Documents preprocessing pipeline (labeling, stratification by severity)
  - Describes integration approach (TensorFlow Lite for offline on-device inference)
- **Purpose**: Establishes scientific rigor and methodology transparency

### 2. Research & Optimization Approach
- **Methodology Cards** (icon-led rows):
  - Deductive Approach — hypotheses tested against benchmarks
  - Design-Oriented Methodology — app as artifact and research platform
  - Quantitative Research Design — numerical performance metrics
  - Quantization, Fine-Tuning, Pruning, Knowledge Distillation — optimization techniques explained
- **Visual Design**: Color-coded icons, clear descriptions for non-technical users

### 3. Ethical Considerations Section
- **Compliance & Privacy**:
  - GDPR and HIPAA compliance design
  - On-device data storage (no cloud sync)
  - Interpretability via attention heatmaps (clinical trust)
  - Class imbalance mitigation (bias reduction)
  - Screening aid disclaimer (not diagnostic replacement)
- **Trust Building**: Addresses real-world clinical deployment concerns

### 4. Developer Contact Card
- **Attribution**:
  - Developer name: Pasindu Bandara
  - Phone number: 071 033 7486 (tap to copy to clipboard)
  - Copyable feedback mechanism for direct communication
- **Accessibility**: No external app dependencies (no URL launcher needed)

---

## SETTINGS PAGE

### 1. Theme Controller Integration
- **State Management**:
  - `ThemeController` singleton holds `ThemeMode` (light/dark)
  - Loaded from SharedPreferences at app startup
  - Notifies listeners on change — triggers MaterialApp rebuild
  - Persisted across app restarts

### 2. Dark Mode Toggle
- **SwitchListTile**:
  - Bound live to `ThemeController.isDarkMode` via `ListenableBuilder`
  - Tap to toggle light ↔ dark mode
  - Subtitle shows current state ("On — using the dark theme" / "Off — using the light theme")
  - Icon changes dynamically (moon/sun)
- **Visual Feedback**: Real-time theme swap across entire app

### 3. Theme Assets
- **Light Theme** (`0xFFF5F7FF` background):
  - Deep purple seed color
  - White cards on light canvas
  - Dark text for readability
- **Dark Theme** (`0xFF0F1115` background):
  - Same deep purple seed color (auto-adjusted brightness)
  - Dark cards on dark canvas
  - Light text for accessibility
- **Consistency**: All screens + cards adapt automatically via `Theme.of(context)`

### 4. Settings Header
- **UI Consistency**:
  - Gradient banner matching app design system
  - Settings icon, title, and subtitle
  - Establishes visual hierarchy

---

## Research Note (50 words)

About/Settings pages implement transparency and UX personalization: project documentation with ethics/methodology builds clinical credibility; developer attribution enables feedback loops. Dark mode via SharedPreferences persistence and ChangeNotifier reactive updates provides accessibility for GDPR data-privacy audits—theme choice is user data—while maintaining WCAG contrast ratios across light and dark palettes. Settings-driven theming eliminates hard-coded colors from app code.
