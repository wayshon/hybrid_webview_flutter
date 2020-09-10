import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class HybridWebview extends StatefulWidget {
  // 加载的网页 URL
  final String url;
  // 来自 webview 的消息
  final Function(String method, dynamic content) callback;

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
    );
  }

  void nativeMessageListener() async {
    _channel.setMethodCallHandler((resultCall) {
      //处理 iOS 发送过来的消息
      MethodCall call = resultCall;
      String method = call.method;
      Map arguments = call.arguments;

      int code = arguments["code"];
      String message = arguments["message"];
      dynamic content = arguments["content"];
      print(
          'method: ${method.toString()}; code: ${code.toString()}; message: ${message.toString()}; content: ${content.toString()}');

      if (widget.callback != null) {
        widget.callback(method, content);
      }
    });
  }
}
