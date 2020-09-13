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
        _context[@"OCObj"] = self;
        
        //接收 初始化参数
        NSDictionary *dic = args;
        NSString *url = [dic valueForKey:@"url"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
        
//        js 注入与回调 block
//        _context[@"jsCallFlutter"] = ^(JSValue *value) {
//            NSArray *arr = [value toArray];
//            id callback = [arr lastObject];
//            [callback callWithArguments:@[@"aaa", @"bbb"]];
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            [dict setObject:[NSNumber numberWithInt:200] forKey:@"code"];
//            [dict setObject:@"jsCallFlutter" forKey:@"message"];
//            [dict setObject:arr[0] forKey:@"content"];
//            [self->_channel invokeMethod:@"jsCallFlutter" arguments:dict];
//        };
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:200] forKey:@"code"];
    [dict setObject:@"webViewDidFinishLoad" forKey:@"message"];
    [_channel invokeMethod:@"finishLoad" arguments:dict];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:500] forKey:@"code"];
    [dict setObject:@"didFailLoadWithError" forKey:@"message"];
    [_channel invokeMethod:@"finishLoad" arguments:dict];
}


-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    if ([[call method] isEqualToString:@"flutterCallJs"]) {
        [_context[@"flutterCallJs"] callWithArguments:@[call.arguments, ^(JSValue *value) {
            NSArray *arr = [value toArray];
            result(arr);
        }]];
    }
}


- (nonnull UIView *)view {
    return _webView;
}

#pragma mark - jsExport
- (void)jsCallFlutter:(JSValue *)params callback:(JSValue *)callback {
    [callback callWithArguments:@[@"aaa", @"bbb"]];
    NSArray *arr = [params toArray];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:200] forKey:@"code"];
    [dict setObject:@"jsCallFlutter" forKey:@"message"];
    [dict setObject:arr forKey:@"content"];
    [self->_channel invokeMethod:@"jsCallFlutter" arguments:dict];
}


@end
