package com.ekycsolutions.ekyc_id_flutter.DocumentScanner

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class DocumentScannerViewFactory(
    private var binding: FlutterPlugin.FlutterPluginBinding,
    private var context: Context
): PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(_s: Context?, viewId: Int, args: Any?): PlatformView {
        return FlutterDocumentScanner(binding, context, viewId)
    }
}