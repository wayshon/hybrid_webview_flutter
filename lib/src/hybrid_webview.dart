import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

void validateParam(dynamic param) {
  if (param == null ||
      param is bool ||
      param is int ||
      param is double ||
      param is String) {
    return;
  }
  if (param is List) {
    for (var v in param) {
      validateParam(v);
    }
  } else if (param is Map) {
    List keys = param.keys.toList();
    for (var k in keys) {
      if (!(k is String)) {
        throw Error.safeToString('map key must string;key: $k');
      }
      validateParam(param[k]);
    }
  } else {
    throw Error.safeToString(
        'param only supply null,int,double,bool,string,list/map;value is $param');
  }
}

@immutable
class HybridWebview extends StatefulWidget {
  // 加载的网页 URL
  final String url;
  // 来自 webview 的消息
  final Future<dynamic> Function(String method, dynamic content) bridgeListener;

  Future<dynamic> Function(String method, [dynamic arguments]) invokeMethod;

  HybridWebview({
    Key key,
    //webview 加载网页链接
    @required this.url,
    this.bridgeListener,
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
    widget.invokeMethod = (String method, [dynamic arguments]) {
      try {
        validateParam(arguments);
      } catch (e) {
        print(e);
        return null;
      }
      List params = [method];
      if (arguments is List) {
        params.addAll(arguments);
      } else if (arguments != null) {
        params.add(arguments);
      }
      return _channel.invokeMethod('__flutterCallJs', params);
    };
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
      String method = resultCall.method;
      List arguments = resultCall.arguments;

      print(
          'method: ${method.toString()}; arguments: ${arguments.toString()};');

      if (widget.bridgeListener != null) {
        dynamic results = await widget.bridgeListener(method, arguments);
        try {
          validateParam(results);
        } catch (e) {
          print(e);
          results = null;
        }
        if (results == null || results is List) {
          return results;
        }
        return [results];
      }
    });
  }
}
