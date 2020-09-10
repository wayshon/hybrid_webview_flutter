//
//  Webview.h
//  hybrid_webview_flutter
//
//  Created by wangxu-mp on 2020/9/10.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>


NS_ASSUME_NONNULL_BEGIN

@interface Webview : NSObject<FlutterPlatformView>

-(instancetype)initWithWithFrame:(CGRect)frame
                  viewIdentifier:(int64_t)viewId
                       arguments:(id _Nullable)args
                 binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

NS_ASSUME_NONNULL_END
