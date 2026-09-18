package com.dr.diabetic_retinopathy

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
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

    private fun grayscaleArray(bitmap: Bitmap): IntArray {
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
        return gray
    }

    // Mirrors pre_processing.py's create_fundus_mask()/crop_fundus_roi(): threshold at a
    // fixed brightness of 10, take the bounding box of everything above it, pad it, then
    // zero out everything outside a circle fit to that box. No findContours/minEnclosingCircle
    // equivalent exists on-device, so the box IS the region (same simplification used in
    // FundusPreprocessor on the Python side) rather than a true contour fit.
    private fun cropFundusRoi(bitmap: Bitmap): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        val gray = grayscaleArray(bitmap)

        var xMin = width
        var xMax = -1
        var yMin = height
        var yMax = -1

        for (y in 0 until height) {
            for (x in 0 until width) {
                if (gray[y * width + x] > 10) {
                    if (x < xMin) xMin = x
                    if (x > xMax) xMax = x
                    if (y < yMin) yMin = y
                    if (y > yMax) yMax = y
                }
            }
        }

        if (xMax < 0 || yMax < 0) return bitmap

        val padX = maxOf(10, ((xMax - xMin) * 0.08).toInt())
        val padY = maxOf(10, ((yMax - yMin) * 0.08).toInt())

        val cropXMin = maxOf(0, xMin - padX)
        val cropXMax = minOf(width, xMax + padX)
        val cropYMin = maxOf(0, yMin - padY)
        val cropYMax = minOf(height, yMax + padY)

        val centerX = (cropXMin + cropXMax) / 2
        val centerY = (cropYMin + cropYMax) / 2
        val radius = maxOf(cropXMax - cropXMin, cropYMax - cropYMin) / 2
        val radiusSq = radius.toLong() * radius.toLong()

        val srcPixels = IntArray(width * height)
        bitmap.getPixels(srcPixels, 0, width, 0, 0, width, height)

        val outPixels = IntArray(width * height)
        for (y in 0 until height) {
            for (x in 0 until width) {
                val idx = y * width + x
                val inBbox = x in cropXMin until cropXMax && y in cropYMin until cropYMax
                val dx = (x - centerX).toLong()
                val dy = (y - centerY).toLong()
                val inCircle = dx * dx + dy * dy <= radiusSq
                outPixels[idx] = if (inBbox && inCircle) srcPixels[idx] else -0x1000000
            }
        }

        val output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        output.setPixels(outPixels, 0, width, 0, 0, width, height)
        return output
    }

    // Mirrors analyze_dataset.py's detect_bright_region(): 99th-percentile threshold, then
    // the centroid of the largest connected bright blob above it (BFS flood fill in place of
    // findContours + max(contours, key=contourArea) — mathematically the same centroid for a
    // filled region, just without cv2's contour machinery).
    private fun detectBrightRegionQuadrant(bitmap: Bitmap): String? {
        val width = bitmap.width
        val height = bitmap.height
        val gray = grayscaleArray(bitmap)
        val total = gray.size

        val histogram = IntArray(256)
        for (v in gray) histogram[v]++

        var cumulative = 0
        var threshold = 255
        val cutoff = (total * 0.99).toInt()
        for (level in 0..255) {
            cumulative += histogram[level]
            if (cumulative >= cutoff) {
                threshold = level
                break
            }
        }

        val visited = BooleanArray(total)
        var bestSize = 0
        var bestSumX = 0L
        var bestSumY = 0L
        val queue = ArrayDeque<Int>()

        for (start in 0 until total) {
            if (visited[start] || gray[start] <= threshold) continue

            var size = 0
            var sumX = 0L
            var sumY = 0L
            queue.add(start)
            visited[start] = true

            while (queue.isNotEmpty()) {
                val idx = queue.removeFirst()
                val x = idx % width
                val y = idx / width
                size++
                sumX += x
                sumY += y

                for (dy in -1..1) {
                    for (dx in -1..1) {
                        if (dx == 0 && dy == 0) continue
                        val nx = x + dx
                        val ny = y + dy
                        if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue
                        val nIdx = ny * width + nx
                        if (!visited[nIdx] && gray[nIdx] > threshold) {
                            visited[nIdx] = true
                            queue.add(nIdx)
                        }
                    }
                }
            }

            if (size > bestSize) {
                bestSize = size
                bestSumX = sumX
                bestSumY = sumY
            }
        }

        if (bestSize == 0) return null

        val cx = bestSumX / bestSize
        val cy = bestSumY / bestSize

        return when {
            cx < width / 2 && cy < height / 2 -> "Q1"
            cx >= width / 2 && cy < height / 2 -> "Q2"
            cx < width / 2 && cy >= height / 2 -> "Q3"
            else -> "Q4"
        }
    }

    // pre_processing.py: `if bright_region_quadrant not in ["Q2", "Q4"]: flip`.
    // A null quadrant (detection failed) is also "not in" that list in Python, so it flips too.
    private fun shouldFlip(quadrant: String?): Boolean {
        return quadrant != "Q2" && quadrant != "Q4"
    }

    private fun flipHorizontal(bitmap: Bitmap): Bitmap {
        val matrix = Matrix()
        matrix.preScale(-1f, 1f)
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    // Expects an already-cropped bitmap (see cropFundusRoi) — this step is just the
    // grayscale + blur + contrast part of ben_graham_enhancement() in pre_processing.py
    private fun benGrahamEnhancement(bitmap: Bitmap): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        val gray = grayscaleArray(bitmap)

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

    // cv2.GaussianBlur(gray, (0,0), sigmaX=width/30) auto-sizes its kernel to ~6*sigma+1 px,
    // which at full photo resolution (sigma can be 100+) is far too large for a per-pixel
    // O(W*H*kernel^2) loop. Three passes of box blur (P. Kovesi, "Fast Almost-Gaussian
    // Filtering") closely approximate a true Gaussian at that sigma while staying O(W*H)
    // per pass via a running-sum sliding window, regardless of how large the kernel is.
    private fun simpleBlur(gray: IntArray, width: Int, height: Int): IntArray {
        val sigma = width / 30.0
        val boxSizes = gaussianBoxSizes(sigma, 3)

        var current = gray
        for (boxSize in boxSizes) {
            val radius = (boxSize - 1) / 2
            if (radius <= 0) continue
            current = boxBlurVertical(boxBlurHorizontal(current, width, height, radius), width, height, radius)
        }
        return current
    }

    private fun gaussianBoxSizes(sigma: Double, passes: Int): IntArray {
        val wIdeal = Math.sqrt(12.0 * sigma * sigma / passes + 1.0)
        var wl = Math.floor(wIdeal).toInt()
        if (wl % 2 == 0) wl -= 1
        val wu = wl + 2
        val mIdeal = (12.0 * sigma * sigma - passes * wl * wl - 4.0 * passes * wl - 3.0 * passes) /
            (-4.0 * wl - 4.0)
        val m = Math.round(mIdeal).toInt()
        return IntArray(passes) { i -> if (i < m) wl else wu }
    }

    private fun boxBlurHorizontal(src: IntArray, width: Int, height: Int, radius: Int): IntArray {
        val dst = IntArray(width * height)
        val windowSize = 2 * radius + 1
        for (y in 0 until height) {
            val rowOffset = y * width
            var sum = 0
            for (dx in -radius..radius) {
                sum += src[rowOffset + dx.coerceIn(0, width - 1)]
            }
            dst[rowOffset] = sum / windowSize
            for (x in 1 until width) {
                val addX = (x + radius).coerceIn(0, width - 1)
                val subX = (x - radius - 1).coerceIn(0, width - 1)
                sum += src[rowOffset + addX] - src[rowOffset + subX]
                dst[rowOffset + x] = sum / windowSize
            }
        }
        return dst
    }

    private fun boxBlurVertical(src: IntArray, width: Int, height: Int, radius: Int): IntArray {
        val dst = IntArray(width * height)
        val windowSize = 2 * radius + 1
        for (x in 0 until width) {
            var sum = 0
            for (dy in -radius..radius) {
                sum += src[dy.coerceIn(0, height - 1) * width + x]
            }
            dst[x] = sum / windowSize
            for (y in 1 until height) {
                val addY = (y + radius).coerceIn(0, height - 1)
                val subY = (y - radius - 1).coerceIn(0, height - 1)
                sum += src[addY * width + x] - src[subY * width + x]
                dst[y * width + x] = sum / windowSize
            }
        }
        return dst
    }

    // prefix identifies which pipeline stage this snapshot is from (flip/crop/enhance/ben_graham)
    private fun saveDebugImage(bitmap: Bitmap, prefix: String, originalPath: String, outputDir: String): String? {
        Log.d("PT_INFER", "saveDebugImage[$prefix] called: outputDir=$outputDir, originalPath=$originalPath")
        if (outputDir.isEmpty()) return null
        try {
            val fileName = "${prefix}_${File(originalPath).name}"
            val file = File(outputDir, fileName)
            File(outputDir).mkdirs()
            file.outputStream().use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 95, out)
            }
            Log.d("PT_INFER", "Saved $prefix image: ${file.absolutePath}")
            return file.absolutePath
        } catch (e: Exception) {
            Log.e("PT_INFER", "Failed to save $prefix image", e)
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

                Log.d("PT_INFER", "Detecting bright region for flip decision")
                val quadrant = detectBrightRegionQuadrant(bitmap)
                val oriented = if (shouldFlip(quadrant)) {
                    Log.d("PT_INFER", "Flipping image (quadrant=$quadrant)")
                    flipHorizontal(bitmap)
                } else {
                    bitmap
                }
                saveDebugImage(oriented, "flip", imagePath, outputDir)

                Log.d("PT_INFER", "Cropping fundus ROI at original resolution")
                val cropped = cropFundusRoi(oriented)
                saveDebugImage(cropped, "crop", imagePath, outputDir)

                Log.d("PT_INFER", "Applying Ben Graham enhancement at original resolution")
                val enhancedFullRes = benGrahamEnhancement(cropped)
                saveDebugImage(enhancedFullRes, "enhance", imagePath, outputDir)

                Log.d("PT_INFER", "Resizing enhanced image to 224x224")
                val enhanced = Bitmap.createScaledBitmap(enhancedFullRes, 224, 224, true)
                saveDebugImage(enhanced, "ben_graham", imagePath, outputDir)

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