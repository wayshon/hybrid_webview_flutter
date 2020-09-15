//
//  Webview.m
//  hybrid_webview_flutter
//
//  Created by wangxu-mp on 2020/9/10.
//

#import "Webview.h"

@interface Webview() <JSExportProtocol,UIWebViewDelegate,UIScrollViewDelegate>

@end

@implementation Webview {
    // 创建后的标识
    int64_t _viewId;
    UIWebView * _webView;
    //消息回调
    FlutterMethodChannel* _channel;
    BOOL htmlImageIsClick;
    NSMutableArray* mImageUrlArray;
    JSContext *_context;
    NSString *_bridgeJSString;
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
        
        //创建context
        _context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        //设置异常处理
        _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            [JSContext currentContext].exception = exception;
            NSLog(@"exception:%@",exception);
        };
        
        //将obj添加到context中
        _context[@"__OCObj"] = self;
        
        //接收 初始化参数
        NSDictionary *dic = args;
        NSString *url = [dic valueForKey:@"url"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
        _context[@"callOCOnLoad"] = ^() {
            NSLog(@"window onload ========================== ");
        };
        [_context evaluateScript:@"window.onload = function(){callOCOnLoad()}"];
        
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

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_channel invokeMethod:@"finishLoad" arguments:nil];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_channel invokeMethod:@"failLoad" arguments:error];
}


-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    if ([[call method] isEqualToString:@"__flutterCallJs"]) {
        NSString *action = [call.arguments firstObject];
        NSArray *params;
        if ([call.arguments count] > 1) {
            params = [call.arguments subarrayWithRange:NSMakeRange(1, [call.arguments count] -1)];
        } else {
            params = @[];
        }
        [_context[@"__flutterCallJs"] callWithArguments:@[action, params, ^(JSValue *value) {
            NSArray *arr = [value toArray];
            result(arr);
        }]];
    }
}


- (nonnull UIView *)view {
    return _webView;
}

#pragma mark - jsExport
- (void)jsCallFlutter:(JSValue *)action params:(JSValue *)params callback:(JSValue *)callback {
    NSString *actionName = [NSString stringWithFormat:@"%@", action];
    NSArray *arr = [params toArray];
    [self->_channel invokeMethod:actionName arguments:arr result:^(id  _Nullable result) {
        id error;
        if ([result isKindOfClass:[NSClassFromString(@"FlutterError") class]]) {
            NSLog(@"--------- %@", [result valueForKey:@"_message"]);
            error = [result valueForKey:@"_message"];
        }
        [callback callWithArguments:@[error, result]];
    }];
}


@end
