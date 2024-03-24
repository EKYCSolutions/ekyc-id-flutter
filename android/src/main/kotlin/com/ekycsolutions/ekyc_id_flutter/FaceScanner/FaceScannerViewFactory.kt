package com.ekycsolutions.ekyc_id_flutter.FaceScanner

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class FaceScannerViewFactory(
    private var binding: FlutterPlugin.FlutterPluginBinding,
    private var context: Context
): PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(_s: Context?, viewId: Int, args: Any?): PlatformView {
        return FlutterFaceScanner(binding, context, viewId)
    }
}