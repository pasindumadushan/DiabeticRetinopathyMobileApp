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
                    val outputDir = call.argument<String>("outputDir") ?: ""
                    try {
                        val message = analyze(imagePaths, outputDir)
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

    private fun benGrahamEnhancement(bitmap: Bitmap): Bitmap {
        Log.d("PT_INFER", "Applying Ben Graham enhancement")
        
        val width = bitmap.width
        val height = bitmap.height
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
        
        val gray = IntArray(width * height)
        for (i in pixels.indices) {
            val rgb = pixels[i]
            val r = (rgb shr 16) and 0xFF
            val g = (rgb shr 8) and 0xFF
            val b = rgb and 0xFF
            gray[i] = (0.299 * r + 0.587 * g + 0.114 * b).toInt()
        }
        
        val blurred = simpleBlur(gray, width, height)
        
        val enhanced = IntArray(width * height)
        for (i in gray.indices) {
            val value = (gray[i] * 4 - blurred[i] * 4 + 128).toInt()
            enhanced[i] = value.coerceIn(0, 255)
        }
        
        val result = IntArray(width * height)
        for (i in enhanced.indices) {
            val g_val = enhanced[i]
            result[i] = -0x1000000 or (g_val shl 16) or (g_val shl 8) or g_val
        }
        
        val output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        output.setPixels(result, 0, width, 0, 0, width, height)
        return output
    }
    
    private fun simpleBlur(gray: IntArray, width: Int, height: Int): IntArray {
        val blurred = IntArray(width * height)
        val sigmaX = width / 30.0
        
        for (y in 0 until height) {
            for (x in 0 until width) {
                var sum = 0.0
                var weight = 0.0
                
                for (dy in -3..3) {
                    for (dx in -3..3) {
                        val nx = (x + dx).coerceIn(0, width - 1)
                        val ny = (y + dy).coerceIn(0, height - 1)
                        val gaussian = Math.exp(-(dx * dx + dy * dy) / (2 * sigmaX * sigmaX))
                        sum += gray[ny * width + nx] * gaussian
                        weight += gaussian
                    }
                }
                blurred[y * width + x] = (sum / weight).toInt()
            }
        }
        return blurred
    }

    private fun saveEnhancedImage(bitmap: Bitmap, originalPath: String, outputDir: String): String? {
        Log.d("PT_INFER", "saveEnhancedImage called: outputDir=$outputDir, originalPath=$originalPath")
        if (outputDir.isEmpty()) return null
        try {
            val fileName = "ben_graham_${File(originalPath).name}"
            val file = File(outputDir, fileName)
            File(outputDir).mkdirs()
            file.outputStream().use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 95, out)
            }
            Log.d("PT_INFER", "Saved enhanced image: ${file.absolutePath}")
            return file.absolutePath
        } catch (e: Exception) {
            Log.e("PT_INFER", "Failed to save enhanced image", e)
            return null
        }
    }

    private fun analyze(imagePaths: List<String>, outputDir: String = ""): String {
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

                Log.d("PT_INFER", "Applying Ben Graham enhancement")
                val enhanced = benGrahamEnhancement(resized)
                
                saveEnhancedImage(enhanced, imagePath, outputDir)

                Log.d("PT_INFER", "Creating input tensor")
                val inputTensor = TensorImageUtils.bitmapToFloat32Tensor(
                    enhanced,
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