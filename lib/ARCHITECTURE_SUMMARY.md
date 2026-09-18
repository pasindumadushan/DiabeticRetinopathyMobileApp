# RetinaInsight Architecture (Summary)

RetinaInsight implements a modular, offline-first architecture for clinical diabetic retinopathy screening. The **Flutter frontend** provides patient intake, image capture, and results display across five screens. **SQLite via DatabaseHelper** persists all patient records, images paths, and severity classifications on-device—ensuring HIPAA-compliant data privacy with no cloud dependencies.

The **MethodChannel** bridges Dart and native code, enabling the **PyTorchService** to invoke on-device inference. The **native layer (Android/Kotlin)** loads a lightweight, quantized PyTorch model (5–8 MB), applies Ben Graham contrast enhancement, and returns severity predictions in <2 seconds. **Knowledge distillation, pruning, and quantization** optimize the MobileNet architecture for resource-constrained devices while maintaining clinical accuracy.

**Attention heatmaps** provide interpretability; **severity-stratified recommendations** align with ophthalmology guidelines. The fully offline workflow—from patient intake through diagnosis storage to history replay—requires no internet, making it suitable for clinics in underserved regions. Modular design enables future model updates and platform extensions while maintaining diagnostic reproducibility and audit trails.
