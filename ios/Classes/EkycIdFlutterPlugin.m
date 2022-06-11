#import "EkycIdFlutterPlugin.h"
#if __has_include(<ekyc_id_flutter/ekyc_id_flutter-Swift.h>)
#import <ekyc_id_flutter/ekyc_id_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ekyc_id_flutter-Swift.h"
#endif

@implementation EkycIdFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEkycIdFlutterPlugin registerWithRegistrar:registrar];
}
@end
