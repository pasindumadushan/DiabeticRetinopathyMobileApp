package com.dr.diabetic_retinopathy

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.pytorch.IValue
import org.pytorch.Module
import org.pytorch.torchvision.TensorImageUtils
import java.io.File

class PyTorchInferenceChannel(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    private val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pytorch_inference")
    private val module: Module by lazy {
        val modelFile = File(context.filesDir, "student_quantized.ptl")
        if (!modelFile.exists()) {
            context.assets.open("flutter_assets/lib/assets/ml_model/student_quantized.ptl").use { input ->
                modelFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }
        Module.load(modelFile.absolutePath)
    }

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "analyzeImages" -> {
                    val imagePaths = call.argument<List<String>>("imagePaths").orEmpty()
                    result.success(analyze(imagePaths))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun analyze(imagePaths: List<String>): String {
        if (imagePaths.isEmpty()) {
            return "No images selected."
        }

        val bitmap = BitmapFactory.decodeFile(imagePaths.first())
            ?: return "Unable to decode image."

        val resized = Bitmap.createScaledBitmap(bitmap, 224, 224, true)
        val inputTensor = TensorImageUtils.bitmapToFloat32Tensor(
            resized,
            floatArrayOf(0.485f, 0.456f, 0.406f),
            floatArrayOf(0.229f, 0.224f, 0.225f)
        )

        val output = module.forward(IValue.from(inputTensor)).toTensor()
        val scores = output.dataAsFloatArray
        val predictedIndex = scores.indices.maxByOrNull { scores[it] } ?: 0

        return "Inference complete. Predicted class index: $predictedIndex"
    }
}
