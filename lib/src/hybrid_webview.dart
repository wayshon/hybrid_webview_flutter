import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

@immutable
class HybridWebview extends StatefulWidget {
  // 加载的网页 URL
  final String url;
  // 来自 webview 的消息
  final Future<dynamic> Function(String method, dynamic content) callback;

  HybridWebview({
    Key key,
    //webview 加载网页链接
    @required this.url,
    this.callback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new HybridWebviewState();
}

class HybridWebviewState extends State<HybridWebview> {
  MethodChannel _channel;

  MethodChannel get channel {
    return _channel ?? null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      //ios相关代码
      return buildIosWebView();
    } else {
      return Container();
    }
  }

  Widget buildIosWebView() {
    return UiKitView(
      //调用标识
      viewType: "com.calcbit.hybridWebview",
      //参数初始化
      creationParams: {
        //调用view参数标识
        "url": widget.url,
      },
      //参数的编码方式
      creationParamsCodec: const StandardMessageCodec(),
      //webview 创建后的回调
      onPlatformViewCreated: (id) {
        print("onPlatformViewCreated " + id.toString());
        //创建通道
        _channel = new MethodChannel('com.calcbit.hybridWebview_$id');
        //设置监听
        nativeMessageListener();
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
    );
  }

  void nativeMessageListener() async {
    _channel.setMethodCallHandler((resultCall) async {
      //处理 iOS 发送过来的消息
      String method = resultCall.method;
      Map arguments = resultCall.arguments;

      print(
          'method: ${method.toString()}; arguments: ${arguments.toString()};');

      // if (widget.callback != null) {
      //   final results = await widget.callback(method, arguments);
      //   return results;
      // }
    });
  }
}
