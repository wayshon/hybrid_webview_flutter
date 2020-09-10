#import "HybridWebviewFlutterPlugin.h"
#import "WebviewFactory.h"

@implementation HybridWebviewFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"hybrid_webview_flutter"
            binaryMessenger:[registrar messenger]];
  HybridWebviewFlutterPlugin* instance = [[HybridWebviewFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
  [registrar registerViewFactory:[[WebviewFactory alloc] initWithMessenger:registrar.messenger] withId:@"com.calcbit.hybridWebview"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
