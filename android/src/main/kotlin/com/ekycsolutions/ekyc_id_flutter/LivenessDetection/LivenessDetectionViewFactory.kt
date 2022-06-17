package com.ekycsolutions.ekyc_id_flutter.LivenessDetection

import com.ekycsolutions.ekyc_id_flutter.DocumentScanner.FlutterDocumentScanner

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class LivenessDetectionViewFactory(
    private var binding: FlutterPlugin.FlutterPluginBinding,
    private var context: Context
): PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(_s: Context?, viewId: Int, args: Any?): PlatformView {
        return FlutterLivenessDetection(binding, context, viewId)
    }
}