//
//  DocumentScannerViewFactory.swift
//  ekyc_id_flutter
//
//  Created by Socret Lee on 6/11/22.
//

import Foundation

@available(iOS 10.0, *)
public class DocumentScannerViewFactory: NSObject, FlutterPlatformViewFactory {
    let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return FlutterDocumentScanner(frame: frame, viewId: viewId, messenger: messenger, args: args)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterJSONMessageCodec()
    }
    
    public func applicationDidEnterBackground() {}
    
    public func applicationWillEnterForeground() {}
}
