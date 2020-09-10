import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class HybridWebview extends StatefulWidget {
  //加载的网页 URL
  final String url;

  HybridWebview({
    //webview 加载网页链接
    this.url,
  });

  @override
  State<StatefulWidget> createState() {
    return HybridWebviewState(url);
  }
}

class HybridWebviewState extends State<HybridWebview> {
  //加载的网页 URL
  String url;

  HybridWebviewState(this.url);

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
        "url": url,
      },
      //参数的编码方式
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
