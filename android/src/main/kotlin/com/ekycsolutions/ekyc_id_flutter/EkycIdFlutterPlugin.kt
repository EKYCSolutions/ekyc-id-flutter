package com.ekycsolutions.ekyc_id_flutter

import androidx.annotation.NonNull
import com.ekycsolutions.ekyc_id_flutter.DocumentScanner.DocumentScannerViewFactory
import com.ekycsolutions.ekyc_id_flutter.FaceScanner.FaceScannerViewFactory
import com.ekycsolutions.ekyc_id_flutter.LivenessDetection.LivenessDetectionViewFactory
import com.ekycsolutions.ekycid.EkycID

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** EkycIdFlutterPlugin */
class EkycIdFlutterPlugin: FlutterPlugin, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding
    EkycID.initialize(flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    this.flutterPluginBinding = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.flutterPluginBinding!!.platformViewRegistry.registerViewFactory(
      "DocumentScanner",
      DocumentScannerViewFactory(this.flutterPluginBinding!!, binding.activity)
    )
    this.flutterPluginBinding!!.platformViewRegistry.registerViewFactory(
      "FaceScanner",
      FaceScannerViewFactory(this.flutterPluginBinding!!, binding.activity)
    )
    this.flutterPluginBinding!!.platformViewRegistry.registerViewFactory(
      "LivenessDetection",
      LivenessDetectionViewFactory(this.flutterPluginBinding!!, binding.activity)
    )
  }


  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding);
  }

  override fun onDetachedFromActivity() {

  }
}
