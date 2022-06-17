package com.ekycsolutions.ekyc_id_flutter.DocumentScanner

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.view.LayoutInflater
import android.view.View
import com.ekycsolutions.ekyc_id_flutter.R
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerCameraView
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerEventListener
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerOptions
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerResult
import com.ekycsolutions.ekycid.models.FrameStatus
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream


class FlutterDocumentScanner(
    private var binding: FlutterPlugin.FlutterPluginBinding,
    private var context: Context,
    private val viewId: Int
): PlatformView, MethodChannel.MethodCallHandler, DocumentScannerEventListener {
    private var cameraView: DocumentScannerCameraView? = null
    private var cameraViewView: View = LayoutInflater.from(context as Activity).inflate(R.layout.document_scanner_viewfinder, null)
    private val methodChannel: MethodChannel =
        MethodChannel(binding.binaryMessenger, "DocumentScanner_MethodChannel_$viewId")
    private val eventChannel: EventChannel =
        EventChannel(binding.binaryMessenger, "DocumentScanner_EventChannel_$viewId")
    private val eventStreamHandler = DocumentScannerEventStreamHandler(context)

    init {
        this.cameraView = cameraViewView.findViewById(R.id.documentScannerViewFinder)
        this.methodChannel.setMethodCallHandler(this)
        this.eventChannel.setStreamHandler(eventStreamHandler)
    }


    override fun getView(): View {
        return cameraViewView!!
    }

    override fun dispose() {

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                start(call, result)
            }
            "setWhiteList" -> {
                setWhiteList(call, result)
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
            this.cameraView!!.setOptions(
                DocumentScannerOptions(args["preparingDuration"]!! as Int)
            )
            this.cameraView!!.addListener(this)
            this.cameraView!!.start()
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    private fun disposeFlutter(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (this.cameraView != null) {
                this.cameraView!!.stop()
                this.cameraView = null
            }
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    private fun nextImage(call: MethodCall, result: MethodChannel.Result) {
        try {
            this.cameraView!!.nextImage()
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    private fun setWhiteList(call: MethodCall, result: MethodChannel.Result) {
        try {
            val args = call.arguments as ArrayList<String>
            this.cameraView!!.setWhiteList(args)
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    override fun onInitialize() {
        this.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }

    override fun onDetection(detection: DocumentScannerResult) {
        this.eventStreamHandler?.sendOnDetectionEventToFlutter(detection)
    }

    override fun onFrame(frameStatus: FrameStatus) {
        this.eventStreamHandler?.sendOnFrameEventToFlutter(frameStatus)
    }

    class DocumentScannerEventStreamHandler(private var context: Context) : EventChannel.StreamHandler {
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

        fun sendOnFrameEventToFlutter(frameStatus: FrameStatus) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onFrame"
                    event["values"] = frameStatus.name
                    events!!.success(event)
                }
            }
        }

        fun sendOnDetectionEventToFlutter(detection: DocumentScannerResult) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onDetection"
                    event["values"] = documentScannerResultToFlutterMap(detection)
                    events!!.success(event)
                }
            }
        }

        private fun documentScannerResultToFlutterMap(detection: DocumentScannerResult): HashMap<String, Any?> {
            val values = HashMap<String, Any?>()
            values["documentType"] = detection.documentType.name
            values["documentGroup"] = detection.documentGroup.name
            values["fullImage"] = bitmapToFlutterByteArray(detection.fullImage)
            values["documentImage"] = bitmapToFlutterByteArray(detection.documentImage)
            if (detection.faceImage != null) {
                values["faceImage"] = bitmapToFlutterByteArray(detection.faceImage!!)
            } else {
                values["faceImage"] = null
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