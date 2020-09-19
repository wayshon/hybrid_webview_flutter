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
  } else if ([@"testSession" isEqualToString:call.method]) {
    NSString *str = [self testSession: call.arguments];
    result(str);
  } else if ([@"getCookie" isEqualToString:call.method]) {
    NSArray *list = [self getCookie: call.arguments];
    result(list);
  } else if ([@"setCookie" isEqualToString:call.method]) {
    NSString *domain = [call.arguments objectAtIndex:0];
    NSString *name = [call.arguments objectAtIndex:1];
    NSString *value = [call.arguments objectAtIndex:2];
    NSNumber *exp = [call.arguments objectAtIndex:3];
    [self setCookie:domain Name:name Value:value Expire:exp];
      result(@(YES));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString *)testSession: (NSString *)urlString {
    NSString *result;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"get"];
    NSDictionary *cookieHeaderDic = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [request setValue:[cookieHeaderDic objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ([data length] > 0 && error == nil) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    } else if (error != nil){
        result = [NSString stringWithFormat:@"%@", error];
    }
    return result;
}

- (NSArray *)getCookie: (NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableArray *list = [NSMutableArray new];
    NSArray *cookieArray = [NSArray arrayWithArray:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    for (NSHTTPCookie *obj in cookieArray) {
        if ([url.host isEqualToString: obj.domain]) {
            [list addObject:@{@"name": obj.name,@"value": obj.value}];
        }
    }
    return list;
}

- (void)setCookie: (NSString *)domain Name:(NSString *)name Value:(NSString *)value Expire: (NSNumber *)exp {
    NSMutableDictionary * cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:domain forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:[exp intValue]] forKey:NSHTTPCookieExpires];
    // 通知 webView 设置 cookie
    NSNotification *notification = [NSNotification notificationWithName:@"cookieChange"object:nil userInfo:cookieProperties];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)clearCookie: (NSString *)name {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArray = [NSArray arrayWithArray:[cookieJar cookies]];
    for (NSHTTPCookie *obj in cookieArray) {
        [cookieJar deleteCookie:obj];
    }
}


@end
