#import "FlutterusbPlugin.h"
#if __has_include(<flutterusb/flutterusb-Swift.h>)
#import <flutterusb/flutterusb-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutterusb-Swift.h"
#endif

@implementation FlutterusbPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterusbPlugin registerWithRegistrar:registrar];
}
@end
