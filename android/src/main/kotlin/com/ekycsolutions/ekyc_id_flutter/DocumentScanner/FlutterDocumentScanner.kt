package com.ekycsolutions.ekyc_id_flutter.DocumentScanner

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.annotation.RequiresApi
import com.ekycsolutions.ekyc_id_flutter.R
import com.ekycsolutions.ekycid.core.models.FrameStatus
import com.ekycsolutions.ekycid.core.objectdetection.ObjectDetectionObjectTypeStringToObjectTypeMapping
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerEventListener
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerOptions
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerResult
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerView
import com.ekycsolutions.ekycid.documentscanner.DocumentSide
import com.ekycsolutions.ekycid.documentscanner.ScannableDocument
import com.ekycsolutions.ekycid.documentscanner.cameraview.DocumentScannerCameraOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.ByteArrayOutputStream
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap


class FlutterDocumentScanner(
    private var binding: FlutterPlugin.FlutterPluginBinding,
    private var context: Context,
    private val viewId: Int
): PlatformView, MethodChannel.MethodCallHandler, DocumentScannerEventListener {
    private var scanner: DocumentScannerView? = null

    private var scannerView: LinearLayout = LinearLayout(context)
    private val methodChannel: MethodChannel =
        MethodChannel(binding.binaryMessenger, "DocumentScanner_MethodChannel_$viewId")
    private val eventChannel: EventChannel =
        EventChannel(binding.binaryMessenger, "DocumentScanner_EventChannel_$viewId")
    private val eventStreamHandler = DocumentScannerEventStreamHandler(context)

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
            "reset" -> {
                reset(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        Log.d("START","Processing is starting")
        try {
            val args = call.arguments as HashMap<*, *>
            val cameraOptions = args["cameraOptions"] as HashMap<String, Any>
            val scannableDocuments = args["scannableDocuments"] as ArrayList<HashMap<String, Any>>

            this.scanner = DocumentScannerView(context)
            this.scanner!!.addListener(this)
            this.scanner!!.start(
                DocumentScannerOptions(
                    DocumentScannerCameraOptions(
                        cameraOptions["captureDurationCountDown"] as Int,
                        (cameraOptions["faceCropScale"] as Double).toFloat(),
                        (cameraOptions["roiSize"] as Double).toFloat(),
                        (cameraOptions["minDocWidthPercentage"] as Double).toFloat(),
                        (cameraOptions["maxDocWidthPercentage"] as Double).toFloat(),
                    ),
                    ArrayList(scannableDocuments.map {
                        ScannableDocument(
                            ObjectDetectionObjectTypeStringToObjectTypeMapping[it["mainSide"]!!]!!,
                            if (it["secondarySide"] != null) ObjectDetectionObjectTypeStringToObjectTypeMapping[it["secondarySide"]!!] else null,
                        )
                    }),
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

    private fun reset(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (this.scanner != null) {
                this.scanner!!.reset()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error(e.toString(), e.message, "")
        }
    }

    override fun onInitialized() {
        this.eventStreamHandler?.sendOnInitializedEventToFlutter()
    }

    @RequiresApi(Build.VERSION_CODES.N)
    override fun onDocumentScanned(mainSide: DocumentScannerResult, secondarySide: DocumentScannerResult?) {
        this.eventStreamHandler?.sendOnDocumentScannedEventToFlutter(mainSide, secondarySide)
    }

    override fun onFrameStatusChanged(frameStatus: FrameStatus) {
        this.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }

    override fun onCaptureCountDownChanged(current: Int, max: Int) {
        this.eventStreamHandler?.sendOnCaptureCountDownChangedEventToFlutter(current, max)
    }

    override fun onCurrentSideChanged(currentSide: DocumentSide) {
        this.eventStreamHandler?.sendOnCurrentSideChangedEventToFlutter(currentSide)
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

        @RequiresApi(Build.VERSION_CODES.N)
        fun sendOnDocumentScannedEventToFlutter(mainSide: DocumentScannerResult, secondarySide: DocumentScannerResult?) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onDocumentScanned"
                    val values = HashMap<String, Any?>()
                    values["mainSide"] = documentScannerResultToFlutterMap(mainSide)
                    if (secondarySide!=null) {
                        values["secondarySide"] = documentScannerResultToFlutterMap(secondarySide!!)
                    }

                    event["values"] = values
                    events!!.success(event)
                }
            }
        }


        fun sendOnCurrentSideChangedEventToFlutter(currentSide: DocumentSide) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onCurrentSideChanged"
                    event["values"] = currentSide.name
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

        @RequiresApi(Build.VERSION_CODES.N)
        private fun documentScannerResultToFlutterMap(detection: DocumentScannerResult): HashMap<String, Any?> {
            val values = HashMap<String, Any?>()
            val temp = detection.toMap(context, saveImage = false)
            values["documentType"] = temp["documentType"]
            values["documentGroup"] = temp["documentGroup"]
            values["fullImage"] = bitmapToFlutterByteArray(temp["fullImage"] as Bitmap)
            values["documentImage"] = bitmapToFlutterByteArray(temp["documentImage"] as Bitmap)
            if (detection.faceImage != null) {
                values["faceImage"] = bitmapToFlutterByteArray(temp["faceImage"] as Bitmap)
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