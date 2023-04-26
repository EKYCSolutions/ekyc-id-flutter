package com.ekycsolutions.ekyc_id_flutter.DocumentScanner

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import com.ekycsolutions.ekyc_id_flutter.R
import com.ekycsolutions.ekycid.core.models.FrameStatus
import com.ekycsolutions.ekycid.core.objectdetection.ObjectDetectionObjectType
import com.ekycsolutions.ekycid.documentscanner.*
import com.ekycsolutions.ekycid.documentscanner.cameraview.DocumentScannerCameraOptions
import com.ekycsolutions.ekycid.documentscanner.overlays.DocumentScannerOverlayOptions
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
    private var cameraView: DocumentScannerView? = null
    private var cameraViewView: View = LayoutInflater.from(context as Activity).inflate(R.layout.document_scanner_viewfinder, null)
    private val methodChannel: MethodChannel =
        MethodChannel(binding.binaryMessenger, "DocumentScanner_MethodChannel_$viewId")
    private val eventChannel: EventChannel =
        EventChannel(binding.binaryMessenger, "DocumentScanner_EventChannel_$viewId")
    private val eventStreamHandler = DocumentScannerEventStreamHandler(context)

    private val OBJECT_TYPE_MAPPING : HashMap<String,ObjectDetectionObjectType> = hashMapOf(
        "COVID_19_VACCINATION_CARD_0" to  ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_0,

    "COVID_19_VACCINATION_CARD_0_BACK" to  ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_0_BACK,

    "COVID_19_VACCINATION_CARD_1" to  ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_1,

    "COVID_19_VACCINATION_CARD_1_BACK" to  ObjectDetectionObjectType.COVID_19_VACCINATION_CARD_1_BACK,

    "DRIVER_LICENSE_0" to ObjectDetectionObjectType.DRIVER_LICENSE_0,

    "DRIVER_LICENSE_BACK_0" to ObjectDetectionObjectType.DRIVER_LICENSE_0_BACK,

    "DRIVER_LICENSE_1" to  ObjectDetectionObjectType.DRIVER_LICENSE_1,

    "DRIVER_LICENSE_1_BACK" to ObjectDetectionObjectType.DRIVER_LICENSE_1_BACK,

    "LICENSE_PLATE_0_0" to ObjectDetectionObjectType.LICENSE_PLATE_0_0,

    "LICENSE_PLATE_0_1" to ObjectDetectionObjectType.LICENSE_PLATE_0_1,

    "LICENSE_PLATE_1_0" to ObjectDetectionObjectType.LICENSE_PLATE_1_0,

    "LICENSE_PLATE_2_0" to ObjectDetectionObjectType.LICENSE_PLATE_2_0,

    "LICENSE_PLATE_3_0" to ObjectDetectionObjectType.LICENSE_PLATE_3_0,

    "LICENSE_PLATE_3_1" to ObjectDetectionObjectType.LICENSE_PLATE_3_1,

    "NATIONAL_ID_0" to ObjectDetectionObjectType.NATIONAL_ID_0,

    "NATIONAL_ID_0_BACK" to ObjectDetectionObjectType.NATIONAL_ID_0_BACK,

    "NATIONAL_ID_1" to ObjectDetectionObjectType.NATIONAL_ID_1,

    "NATIONAL_ID_1_BACK" to ObjectDetectionObjectType.NATIONAL_ID_1_BACK,

    "NATIONAL_ID_2" to ObjectDetectionObjectType.NATIONAL_ID_2,

    "NATIONAL_ID_2_BACK" to ObjectDetectionObjectType.NATIONAL_ID_2_BACK,

    "PASSPORT_0" to ObjectDetectionObjectType.PASSPORT_0,

    "PASSPORT_0_:P" to ObjectDetectionObjectType.PASSPORT_0_TOP,

    "SUPERFIT_0" to ObjectDetectionObjectType.SUPERFIT_0,

    "SUPERFIT_0_BACK" to ObjectDetectionObjectType.SUPERFIT_0_BACK,

    "VEHICLE_REGISTRATION_0" to ObjectDetectionObjectType.VEHICLE_REGISTRATION_0,

    "VEHICLE_REGISTRATION_0_BACK" to ObjectDetectionObjectType.VEHICLE_REGISTRATION_0_BACK,

    "VEHICLE_REGISTRATION_1" to ObjectDetectionObjectType.VEHICLE_REGISTRATION_1,

    "VEHICLE_REGISTRATION_1_BACK" to ObjectDetectionObjectType.VEHICLE_REGISTRATION_1_BACK,

    "VEHICLE_REGISTRATION_2" to ObjectDetectionObjectType.VEHICLE_REGISTRATION_2
    )

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
            "dispose" -> {
                disposeFlutter(call, result)
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
            val scannableDocuments = args["scannableDocuments"] as ArrayList<HashMap<String,Any>>
            val preparingDuration = args["preparingDuration"] as Int
            this.cameraView!!.addListener(this)
            this.cameraView!!.start(options = DocumentScannerOptions(
                cameraOptions = DocumentScannerCameraOptions(preparingDuration),
                scannableDocuments = ArrayList(scannableDocuments.map{
                    ScannableDocument(
                        mainSide  = OBJECT_TYPE_MAPPING[it["mainSide"]]!!,
                        secondarySide = OBJECT_TYPE_MAPPING[it["secondarySide"]]
                    )
                })
            ),
                langOptions = DocumentScannerOverlayOptions()
            )
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

//        fun sendOnFrameEventToFlutter(frameStatus: FrameStatus) {
//            Log.d("OnFrame", "OnFrame")
//            if (events != null) {
//                (context as Activity).runOnUiThread {
//                    val event = HashMap<String, Any>()
//                    event["type"] = "onFrame"
//                    event["values"] = frameStatus.name
//                    events!!.success(event)
//                }
//            }
//        }
        // 3 functions here

        fun sendOnCurrentSideChangedEventToFlutter(currentSide: DocumentSide){
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onCurrentSideChanged"
                    event["values"] = currentSide.name.uppercase()
                    events!!.success(event)
                }
            }
        }

        fun sendOnFrameStatusChangedEventToFlutter(frameStatus: FrameStatus){
            Log.d("OnFrame","OnFrame")
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String,Any>()
                    event["type"] = "onFrameStatusChanged"
                    event["values"] = frameStatus.name
                    events!!.success(event)
                }
            }
            Log.d("OnFrame","OnnnnFrameeeee")
        }

        fun sendOnDocumentScannedEventToFlutter(mainSide: DocumentScannerResult,secondarySide: DocumentScannerResult?){
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onDocumentScanned"
                    val values  = HashMap<String,Any>()
                    values["mainSide"] = documentScannerResultToFlutterMap(mainSide)

//                    values["mainSide"] = mainSide.toMap(context, saveImage = false)

                    if(secondarySide!=null){
//                        values["secondarySide"] = secondarySide.toMap(context)
                        values["secondarySide"] = documentScannerResultToFlutterMap(secondarySide)
//                        values["secondarySide"] = secondarySide.toMap(context, saveImage = false)
                    }
                    event["values"] = values
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

    override fun onCurrentSideChanged(currentSide: DocumentSide) {
        // gets called every time scanning of current side is finished
        // when switch side, get and send current side to flutter
        Log.d("onCurrentSideChanged",currentSide.toString())
        this.eventStreamHandler?.sendOnCurrentSideChangedEventToFlutter(currentSide)
    }

    override fun onDocumentScanned(
        mainSide: DocumentScannerResult,
        secondarySide: DocumentScannerResult?
    ) {
        // when scanning of both sides are done
        this.eventStreamHandler?.sendOnDocumentScannedEventToFlutter(mainSide,secondarySide)
    }

    override fun onFrameStatusChanged(frameStatus: FrameStatus) {
        Log.d("onFrameStatusChanged",frameStatus.toString())
        // called every frame
        this.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }
}