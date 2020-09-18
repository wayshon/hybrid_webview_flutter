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
    int _lastPosition;
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
        
        //将self添加到context中
        _context[@"__OCObj"] = self;
        
        //接收 初始化参数
        NSString *url = [args valueForKey:@"url"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
        _context[@"console"][@"log"] = ^(JSValue * msg) {
            NSLog(@"H5  log : %@", msg);
        };
        _context[@"console"][@"warn"] = ^(JSValue * msg) {
            NSLog(@"H5  warn : %@", msg);
        };
        _context[@"console"][@"error"] = ^(JSValue * msg) {
            NSLog(@"H5  error : %@", msg);
        };
        
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

- (nonnull UIView *)view {
    return _webView;
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
        //  在主线程更新 webview，不然会崩
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_context[@"__flutterCallJs"] callWithArguments:@[action, params, ^(JSValue *value) {
                NSArray *arr = [value toArray];
                result(arr);
            }]];
        });
    } else if ([[call method] isEqualToString:@"evaluateJavaScript"]) {
        // 注入 js
        NSString* jsString = [call arguments];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_webView stringByEvaluatingJavaScriptFromString:jsString];
        });
    }
}

#pragma mark - webView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_channel invokeMethod:@"webViewDidStartLoad" arguments:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_channel invokeMethod:@"webViewDidFinishLoad" arguments:nil];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_channel invokeMethod:@"didFailLoadWithError" arguments:error.localizedDescription];
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_channel invokeMethod:@"scrollViewWillBeginDragging" arguments:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_channel invokeMethod:@"scrollViewDidEndDragging" arguments:@[@(decelerate)]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int currentPostion = scrollView.contentOffset.y;
    if (currentPostion - _lastPosition > 25) {
        _lastPosition = currentPostion;
        [_channel invokeMethod:@"scrollForwardTop" arguments:@[@(_lastPosition)]];
    }
    else if (_lastPosition - currentPostion > 25) {
        _lastPosition = currentPostion;
        [_channel invokeMethod:@"scrollForwardBottom" arguments:@[@(_lastPosition)]];
    }
}

#pragma mark - jsExport
- (void)jsCallFlutter:(JSValue *)action params:(JSValue *)params callback:(JSValue *)callback {
    NSString *actionName = [NSString stringWithFormat:@"%@", action];
    NSArray *arr = [params toArray];
    [self->_channel invokeMethod:actionName arguments:arr result:^(id  _Nullable result) {
        if ([result isKindOfClass:[NSClassFromString(@"FlutterError") class]]) {
            [callback callWithArguments:@[[result valueForKey:@"_message"], [NSNull null]]];
        } else {
            id results;
            if (result) {
                results = result;
            } else {
                results = [NSNull null];
            }
            //  在主线程更新 webview
            dispatch_async(dispatch_get_main_queue(), ^{
                [callback callWithArguments:@[[NSNull null], results]];
            });
        }
    }];
}


@end
