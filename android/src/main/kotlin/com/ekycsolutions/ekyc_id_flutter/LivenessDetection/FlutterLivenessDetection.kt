package com.ekycsolutions.ekyc_id_flutter.LivenessDetection

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import com.ekycsolutions.ekyc_id_flutter.R

import com.ekycsolutions.ekycid.livenessdetection.*
import com.ekycsolutions.ekycid.core.models.FrameStatus
import com.ekycsolutions.ekycid.documentscanner.DocumentScannerResult
import com.ekycsolutions.ekycid.livenessdetection.cameraview.LivenessDetectionCameraOptions
import com.ekycsolutions.ekycid.livenessdetection.cameraview.LivenessFace
import com.ekycsolutions.ekycid.livenessdetection.cameraview.LivenessPromptType
import com.ekycsolutions.ekycid.livenessdetection.overlays.LivenessDetectionOverlayOptions
import com.ekycsolutions.ekycid.utils.EkycIDLanguage
import io.flutter.plugin.common.EventChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import okhttp3.internal.toImmutableList
import org.intellij.lang.annotations.Language
import java.io.ByteArrayOutputStream
import java.util.Collections

class FlutterLivenessDetection(
    private var binding: FlutterPlugin.FlutterPluginBinding,
    private var context: Context,
    private val viewId: Int
) : PlatformView, MethodChannel.MethodCallHandler, LivenessDetectionEventListener {
    private var cameraView: LivenessDetectionView? = null
    private var cameraViewView: View = LayoutInflater.from(context as Activity).inflate(R.layout.liveness_detection_viewfinder, null)
    private val methodChannel: MethodChannel =
        MethodChannel(binding.binaryMessenger, "LivenessDetection_MethodChannel_$viewId")
    private val eventChannel: EventChannel =
        EventChannel(binding.binaryMessenger, "LivenessDetection_EventChannel_$viewId")
    private val eventStreamHandler = LivenessDetectionEventStreamHandler(context)

    private val LIVENESS_PROMPT_TYPE_MAPPING: HashMap<String, LivenessPromptType> = hashMapOf(
        "BLINKING" to LivenessPromptType.BLINKING,
        "LOOK_LEFT" to LivenessPromptType.LOOK_LEFT,
        "LOOK_RIGHT" to LivenessPromptType.LOOK_RIGHT
    )

    private val promptTypes: ArrayList<LivenessPromptType> = arrayListOf(
        LivenessPromptType.BLINKING,
        LivenessPromptType.LOOK_LEFT,
        LivenessPromptType.LOOK_RIGHT
    )

    init {
        this.cameraView = cameraViewView.findViewById(R.id.livenessDetectionViewFinder)
        this.methodChannel.setMethodCallHandler(this)
        this.eventChannel.setStreamHandler(eventStreamHandler)
    }


    override fun getView(): View {
        return cameraViewView
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
        try {
            val args = call.arguments as HashMap<*, *>
//            val prompts = args["prompts"] as ArrayList<String>
//            val prompts = args["prompts"] as ArrayList<HashMap<String,Any>>
            val promptTimerCountDownSec = args["promptTimerCountDownSec"] as Int
            val promptTypesIndexList = args["prompts"] as ArrayList<Int>
            val promptTypes = promptTypesIndexList.map { promptTypes[it] } as ArrayList<LivenessPromptType>
            this.cameraView!!.addListener(this)
            this.cameraView!!.start(LivenessDetectionOptions(
                cameraOptions = LivenessDetectionCameraOptions(promptTypes,promptTimerCountDownSec)),
                langOptions = LivenessDetectionOverlayOptions()
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

    override fun onActivePromptChanged(activePrompt: LivenessPromptType?) {

        this.eventStreamHandler?.sendOnActivePromptChangedEventToFlutter(activePrompt)
    }

    override fun onCountDownChanged(current: Int, max: Int) {
        this.eventStreamHandler.sendOnCountDownChangedEventToFlutter(current, max)
    }

    override fun onFocusChanged(isFocusing: Boolean) {

        this.eventStreamHandler?.sendOnFocusChangedEventToFlutter(isFocusing)
    }

    override fun onFrameStatusChanged(frameStatus: FrameStatus) {

        this.eventStreamHandler?.sendOnFrameStatusChangedEventToFlutter(frameStatus)
    }

    override fun onLivenessTestCompleted(result: LivenessDetectionResult) {

        this.eventStreamHandler?.sendOnLivenessTestCompletedEventToFlutter(result)
    }

    override fun onProgressChanged(progress: Float) {

        this.eventStreamHandler?.sendOnProgressChangedEventToFlutter(progress)
    }


    class LivenessDetectionEventStreamHandler(private var context: Context) :
        EventChannel.StreamHandler {
        private var events: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            this.events = events
        }

        override fun onCancel(arguments: Any?) {
            this.events = null
        }

        fun sendOnActivePromptChangedEventToFlutter(activePrompt: LivenessPromptType?){
            if (events != null){
                (context as Activity).runOnUiThread{
                    val event = HashMap<String,Any>()
                    event["type"] = "OnActivePrompt"
                    event["values"] = "LivenessPromptType.$activePrompt"
                    events!!.success(event)
                }
            }
        }

        fun sendOnInitializedEventToFlutter() {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onInitialized"
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

        fun sendOnFocusChangedEventToFlutter(isFocusing: Boolean){
            if(events != null){
                (context as Activity).runOnUiThread{
                    val event = HashMap<String,Any>()
                    event["type"] = "OnFocusChanged"
                    event["values"] = isFocusing
                    events!!.success(event)
                }
            }
        }

        fun sendOnFrameStatusChangedEventToFlutter(frameStatus: FrameStatus){
            if (events != null) {
                (context as Activity).runOnUiThread{
                    val event = HashMap<String,Any>()
                    event["type"]="OnFrameStatusChanged"
                    event["values"]=frameStatus.name
                    events!!.success(event)
                }
            }
        }

        fun sendOnProgressChangedEventToFlutter(progress: Float){
            if (events != null){
                (context as Activity).runOnUiThread {
                    val event = HashMap<String,Any>()
                    event["type"] = "OnProgressChanged"
                    event["values"]=progress
                    events!!.success(event)
                }
            }
        }

        fun sendOnLivenessTestCompletedEventToFlutter(result : LivenessDetectionResult){
            if (events!=null){
                (context as Activity).runOnUiThread{
                    val event = HashMap<String,Any>()
                    event["type"] = "OnLivenessTestCompleted"
                    event["values"] = result.toMap(context)
                    events!!.success(event)
                }
            }
        }



        fun sendOnAllPromptsCompletedEventToFlutter(detection: LivenessDetectionResult) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onAllPromptsCompleted"
//                    event["values"] = livenessDetectionResultToFlutterMap(detection)
                    events!!.success(event)
                }
            }
        }

        fun sendOnPromptCompletedEventToFlutter(
            completedPromptIndex: Int,
            success: Boolean,
            progress: Float
        ) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onPromptCompleted"
                    val values = HashMap<String, Any?>()
                    values["completedPromptIndex"] = completedPromptIndex
                    values["success"] = success
                    values["progress"] = progress
                    event["values"] = values
                    events!!.success(event)
                }
            }
        }

        fun sendOnCountDownChangedEventToFlutter(current: Int, max: Int) {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onCountDownChanged"
                    val values = HashMap<String, Any?>()
                    values["current"] = current
                    values["max"] = max
                    event["values"] = values
                    events!!.success(event)
                }
            }
        }

        fun sendOnFocusEventToFlutter() {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onFocus"
                    events!!.success(event)
                }
            }
        }

        fun sendOnFocusDroppedEventToFlutter() {
            if (events != null) {
                (context as Activity).runOnUiThread {
                    val event = HashMap<String, Any>()
                    event["type"] = "onFocusDropped"
                    events!!.success(event)
                }
            }
        }

//        private fun livenessDetectionResultToFlutterMap(detection: LivenessDetectionResult): HashMap<String, Any?> {
//            val values = HashMap<String, Any?>()
//
//            if (detection.frontFace != null) {
//                values["frontFace"] = livenessFaceToFlutterMap(detection.frontFace!!)
//            } else {
//                values["frontFace"] = null
//            }
//
//            if (detection.leftFace != null) {
//                values["leftFace"] = livenessFaceToFlutterMap(detection.leftFace!!)
//            } else {
//                values["leftFace"] = null
//            }
//
//            if (detection.rightFace != null) {
//                values["rightFace"] = livenessFaceToFlutterMap(detection.rightFace!!)
//            } else {
//                values["rightFace"] = null
//            }
//
//            Log.d("livenessDetectionResult", detection.prompts.toString())
//
//            var ps = arrayListOf<HashMap<String,Any?>>()
//
//            for (p in detection.prompts) {
//                val v = HashMap<String, Any?>()
//                v["prompt"] = p.prompt.name
//                v["success"] = p.success
//                ps.add(v)
//            }
//
//            values["prompts"] = ps
//
//            return values
//        }
//
//        private fun livenessFaceToFlutterMap(livenessFace: LivenessFace): HashMap<String, Any?> {
//            var values = HashMap<String, Any?>()
//            values["image"] = bitmapToFlutterByteArray(livenessFace.image!!)
//            values["leftEyeOpenProbability"] = livenessFace.leftEyeOpenProbability
//            values["rightEyeOpenProbability"] = livenessFace.rightEyeOpenProbability
//            values["headEulerAngleX"] = livenessFace.headEulerAngleX
//            values["headEulerAngleY"] = livenessFace.headEulerAngleY
//            values["headEulerAngleZ"] = livenessFace.headEulerAngleZ
//
//            if (livenessFace.headDirection != null) {
//                values["headDirection"] = livenessFace.headDirection!!.name
//            } else {
//                values["headDirection"] = null
//            }
//
//            if (livenessFace.eyesStatus != null) {
//                values["eyesStatus"] = livenessFace.eyesStatus!!.name
//            } else {
//                values["eyesStatus"] = null
//            }
//
//            return values
//        }

        private fun bitmapToFlutterByteArray(image: Bitmap): ByteArray {
            val stream = ByteArrayOutputStream()
            image.compress(Bitmap.CompressFormat.JPEG, 90, stream)
            return stream.toByteArray()
        }
    }
}