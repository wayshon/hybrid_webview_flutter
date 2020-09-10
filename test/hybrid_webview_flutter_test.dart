import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hybrid_webview_flutter/hybrid_webview_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('hybrid_webview_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HybridWebviewFlutter.platformVersion, '42');
  });
}
