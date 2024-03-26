package com.ekycsolutions.ekyc_id_flutter.FaceScanner

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.view.View
import android.widget.LinearLayout
import com.ekycsolutions.ekyc_id_flutter.R
import com.ekycsolutions.ekycid.core.models.FrameStatus
import com.ekycsolutions.ekycid.facescanner.FaceScannerEventListener
import com.ekycsolutions.ekycid.facescanner.FaceScannerOptions
import com.ekycsolutions.ekycid.facescanner.FaceScannerView
import com.ekycsolutions.ekycid.facescanner.cameraview.FaceScannerCameraOptions
import com.ekycsolutions.ekycid.livenessdetection.cameraview.LivenessFace
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream


class FlutterFaceScanner(
    private var binding: FlutterPlugin.FlutterPluginBinding,
    private var context: Context,
    private val viewId: Int
): PlatformView, MethodChannel.MethodCallHandler, FaceScannerEventListener {
    private var scanner: FaceScannerView? = null

    private var scannerView: LinearLayout = LinearLayout(context)
    private val methodChannel: MethodChannel =
        MethodChannel(binding.binaryMessenger, "FaceScanner_MethodChannel_$viewId")
    private val eventChannel: EventChannel =
        EventChannel(binding.binaryMessenger, "FaceScanner_EventChannel_$viewId")
    private val eventStreamHandler = FaceScannerEventStreamHandler(context)

    init {
        this.methodChannel.setMethodCallHandler(this)
        this.eventChannel.setStreamHandler(eventStreamHandler)
    }


    override fun getView(): View {
        return scannerView
    }

    override fun dispose() {

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                start(call, result)
            }
            "nextImage" -> {
                nextImage(call, result)
            }
            "dispose" -> {
                disposeFlutter(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        try {
            val args = call.arguments as HashMap<*, *>
            val useFrontCamera = args["useFrontCamera"] as Boolean
            val cameraOptions = args["cameraOptions"] as HashMap<String, Any>
            this.scanner = FaceScannerView(context, useFrontCamera)
            this.scanner!!.addListener(this)
            this.scanner!!.start(
                FaceScannerOptions(
                    FaceScannerCameraOptions(
                        cameraOptions["captureDurationCountDown"] as Int,
                        cameraOptions["faceCropScale"] as Float,
                        cameraOptions["roiSize"] as Float,
                        cameraOptions["minFaceWidthPercentage"] as Float,
                        cameraOptions["maxFaceWidthPercentage"] as Float,
                    )
                )
            )

            this.scanner!!.layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
            this.scannerView.addView(this.scanner)
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    private fun disposeFlutter(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (this.scanner != null) {
                this.scanner!!.stop()
                this.scanner = null
            }
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    private fun nextImage(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (this.scanner != null) {
                this.scanner!!.nextImage()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    override fun onInitialized() {
        this.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }

    override fun onFaceScanned(face: LivenessFace) {
        this.eventStreamHandler?.sendOnFaceScannedEventToFlutter(face)
    }

    override fun onFrameStatusChanged(frameStatus: FrameStatus) {
        this.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }

    override fun onCaptureCountDownChanged(current: Int, max: Int) {
        this.eventStreamHandler?.sendOnCaptureCountDownChangedEventToFlutter(current, max)
    }

    class FaceScannerEventStreamHandler(private var context: Context) : EventChannel.StreamHandler {
        private var events: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            this.events = events
        }

        override fun onCancel(arguments: Any?) {
            this.events = null
        }

        fun sendOnInitializedEventToFlutter() {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onInitialized"
                    val values = HashMap<String, Any?>()
                    event["values"] = values
                    events!!.success(event)
                }
            }
        }

        fun sendOnFrameStatusChangedEventToFlutter(frameStatus: FrameStatus) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onFrameStatusChanged"
                    event["values"] = frameStatus.name
                    events!!.success(event)
                }
            }
        }

        fun sendOnFaceScannedEventToFlutter(face: LivenessFace) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onFaceScanned"
                    event["values"] = livenessFaceToFlutterMap(face)
                    events!!.success(event)
                }
            }
        }

        fun sendOnCaptureCountDownChangedEventToFlutter(current: Int, max: Int) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onCaptureCountDownChanged"
                    val values = HashMap<String, Any?>()
                    values["current"] = current
                    values["max"] = max
                    event["values"] = values
                    events!!.success(event)
                }
            }
        }

        private fun livenessFaceToFlutterMap(livenessFace: LivenessFace): HashMap<String, Any?> {
            var values = HashMap<String, Any?>()
            values["image"] = bitmapToFlutterByteArray(livenessFace.image!!)
            values["leftEyeOpenProbability"] = livenessFace.leftEyeOpenProbability
            values["rightEyeOpenProbability"] = livenessFace.rightEyeOpenProbability
            values["headEulerAngleX"] = livenessFace.headEulerAngleX
            values["headEulerAngleY"] = livenessFace.headEulerAngleY
            values["headEulerAngleZ"] = livenessFace.headEulerAngleZ

            if (livenessFace.headDirection != null) {
                values["headDirection"] = livenessFace.headDirection!!.name
            } else {
                values["headDirection"] = null
            }

            if (livenessFace.eyesStatus != null) {
                values["eyesStatus"] = livenessFace.eyesStatus!!.name
            } else {
                values["eyesStatus"] = null
            }

            return values
        }

        private fun bitmapToFlutterByteArray(image: Bitmap): ByteArray {
            val stream = ByteArrayOutputStream()
            image.compress(Bitmap.CompressFormat.JPEG, 90, stream)
            return stream.toByteArray()
        }
    }
}