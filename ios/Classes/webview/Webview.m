//
//  Webview.m
//  hybrid_webview_flutter
//
//  Created by wangxu-mp on 2020/9/10.
//

#import "Webview.h"

#import <JavaScriptCore/JavaScriptCore.h>
@interface Webview() <UIWebViewDelegate,UIScrollViewDelegate>

@end

@implementation Webview {
    // 创建后的标识
    int64_t _viewId;
    UIWebView * _webView;
    //消息回调
    FlutterMethodChannel* _channel;
    BOOL htmlImageIsClick;
    NSMutableArray* mImageUrlArray;
}

-(instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        if (frame.size.width==0) {
            frame=CGRectMake(frame.origin.x, frame.origin.y, [UIScreen mainScreen].bounds.size.width, 22);
        }
        _webView =[[UIWebView alloc] initWithFrame:frame];
        _webView.delegate=self;
        _webView.scrollView.delegate = self;
        _viewId = viewId;
        
        //接收 初始化参数
        NSDictionary *dic = args;
        NSString *url = [dic valueForKey:@"url"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
        
        // 注册flutter 与 ios 通信通道
        NSString* channelName = [NSString stringWithFormat:@"com.calcbit.hybridWebview_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
    }
    return self;
    
}

-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)results{
    if ([[call method] isEqualToString:@"load"]) {
    }
}


- (nonnull UIView *)view {
    return _webView;
}


@end
