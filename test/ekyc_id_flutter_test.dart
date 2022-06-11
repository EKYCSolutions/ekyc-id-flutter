import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ekyc_id_flutter/ekyc_id_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('ekyc_id_flutter');

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
    expect(await EkycIdFlutter.platformVersion, '42');
  });
}
