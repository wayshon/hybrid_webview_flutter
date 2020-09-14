//
//  Webview.h
//  hybrid_webview_flutter
//
//  Created by wangxu-mp on 2020/9/10.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <JavaScriptCore/JavaScriptCore.h>


NS_ASSUME_NONNULL_BEGIN

//定义一个JSExport protocol
@protocol JSExportProtocol <JSExport>

//TODO: 枚举可传递的参数
JSExportAs(jsCallFlutter, - (void)jsCallFlutter:(JSValue *)action params:(JSValue *)params callback:(JSValue *)callback);

@end

@interface Webview : NSObject<FlutterPlatformView>

-(instancetype)initWithWithFrame:(CGRect)frame
                  viewIdentifier:(int64_t)viewId
                       arguments:(id _Nullable)args
                 binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

NS_ASSUME_NONNULL_END
