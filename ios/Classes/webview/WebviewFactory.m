//
//  WebviewFactory.m
//  hybrid_webview_flutter
//
//  Created by wangxu-mp on 2020/9/10.
//  创建视图工厂对象，并在工厂方法中返回需要的原生视图对象
//

#import "WebviewFactory.h"
#import "Webview.h"

@implementation WebviewFactory {
    NSObject<FlutterBinaryMessenger>*_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

//设置参数的编码方式
-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

//用来创建 ios 原生view
- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    //args 为flutter 传过来的参数
    Webview *webView = [[Webview alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return webView;
}

@end
