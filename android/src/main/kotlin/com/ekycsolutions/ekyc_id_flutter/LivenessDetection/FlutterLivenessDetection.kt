package com.ekycsolutions.ekyc_id_flutter.LivenessDetection

import android.annotation.SuppressLint
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
    private val TAG: String? = "FlutterLivenessDetection"
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

    @SuppressLint("LongLogTag")
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
                    event["type"] = "onActivePromptChanged"
                    event["values"] = "LivenessPromptType.$activePrompt"
                    events!!.success(event)
                }
            }
        }


        fun sendOnFocusChangedEventToFlutter(isFocusing: Boolean){
            if(events != null){
                (context as Activity).runOnUiThread{
                    val event = HashMap<String,Any>()
                    event["type"] = "onFocusChanged"
                    event["values"] = isFocusing
                    events!!.success(event)
                }
            }
        }

        fun sendOnFrameStatusChangedEventToFlutter(frameStatus: FrameStatus){
            if (events != null) {
                (context as Activity).runOnUiThread{
                    val event = HashMap<String,Any>()
                    event["type"]="onFrameStatusChanged"
                    event["values"]=frameStatus.name
                    events!!.success(event)
                }
            }
        }

        fun sendOnProgressChangedEventToFlutter(progress: Float){
            if (events != null){
                (context as Activity).runOnUiThread {
                    val event = HashMap<String,Any>()
                    event["type"] = "onProgressChanged"
                    event["values"]=progress
                    events!!.success(event)
                }
            }
        }

        fun sendOnLivenessTestCompletedEventToFlutter(result : LivenessDetectionResult){
            if (events!=null){
                (context as Activity).runOnUiThread{
                    val event = HashMap<String,Any>()
                    event["type"] = "onLivenessTestCompleted"
                    event["values"] = result.toMap(context)
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


    }
}