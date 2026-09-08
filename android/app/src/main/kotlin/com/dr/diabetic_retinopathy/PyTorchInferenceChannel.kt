package com.dr.diabetic_retinopathy

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.pytorch.IValue
import org.pytorch.Module
import org.pytorch.torchvision.TensorImageUtils
import java.io.File

class PyTorchInferenceChannel(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    private val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pytorch_inference")
    private var module: Module? = null

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "analyzeImages" -> {
                    val imagePaths = call.argument<List<String>>("imagePaths").orEmpty()
                    try {
                        val message = analyze(imagePaths)
                        result.success(message)
                    } catch (e: Throwable) {
                        Log.e("PT_INFER", "analyzeImages crashed", e)
                        result.error("PYTORCH_INFERENCE_ERROR", e.message ?: "Unknown native error", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun loadModule(): Module {
        val modelFile = File(context.filesDir, "student_quantized.ptl")
        if (!modelFile.exists()) {
            Log.d("PT_INFER", "Copying model from flutter assets")
            context.assets.open("flutter_assets/lib/assets/ml_model/student_quantized.ptl").use { input ->
                modelFile.outputStream().use { output -> input.copyTo(output) }
            }
        }
        Log.d("PT_INFER", "Loading module from ${modelFile.absolutePath}")
        return Module.load(modelFile.absolutePath)
    }

    private fun getModule(): Module {
        val cached = module
        if (cached != null) return cached
        val loaded = loadModule()
        module = loaded
        return loaded
    }

    private fun analyze(imagePaths: List<String>): String {
        Log.d("PT_INFER", "analyze called, count=${imagePaths.size}")
        if (imagePaths.isEmpty()) return "No images selected."

        val predictions = mutableListOf<Int>()
        val scores = mutableListOf<Float>()

        for ((idx, imagePath) in imagePaths.withIndex()) {
            try {
                Log.d("PT_INFER", "Processing image ${idx + 1}/${imagePaths.size}: $imagePath")
                val bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    Log.e("PT_INFER", "Unable to decode image at $imagePath")
                    continue
                }

                Log.d("PT_INFER", "Resizing image to 224x224")
                val resized = Bitmap.createScaledBitmap(bitmap, 224, 224, true)

                Log.d("PT_INFER", "Creating input tensor")
                val inputTensor = TensorImageUtils.bitmapToFloat32Tensor(
                    resized,
                    floatArrayOf(0.485f, 0.456f, 0.406f),
                    floatArrayOf(0.229f, 0.224f, 0.225f)
                )

                Log.d("PT_INFER", "Running forward pass")
                val outputTensor = getModule().forward(IValue.from(inputTensor)).toTensor()

                val outputScores = outputTensor.dataAsFloatArray
                if (outputScores.isEmpty()) {
                    Log.e("PT_INFER", "Image $idx: Model returned empty output")
                    continue
                }

                var bestIdx = 0
                var bestScore = outputScores[0]
                for (i in 1 until outputScores.size) {
                    if (outputScores[i] > bestScore) {
                        bestScore = outputScores[i]
                        bestIdx = i
                    }
                }

                Log.d("PT_INFER", "Image $idx: class=$bestIdx score=$bestScore")
                predictions.add(bestIdx)
                scores.add(bestScore)
            } catch (e: Throwable) {
                Log.e("PT_INFER", "Error processing image $idx", e)
            }
        }

        if (predictions.isEmpty()) {
            return "Failed to process any images."
        }

        val meanPrediction = predictions.average()
        val roundedClass = meanPrediction.toInt()
        val meanScore = scores.average()

        Log.d("PT_INFER", "All images: predictions=$predictions, mean=$meanPrediction, rounded=$roundedClass, meanScore=$meanScore")
        return "Inference complete. Analyzed ${predictions.size} image(s). Mean severity class: $roundedClass (mean: ${"%.2f".format(meanPrediction)})"
    }
}