import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CallScreeningPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.example.poplar/call_screening',
  );

  Future<void> setRestrictedNumbers(List<String> numbers) async {
    await _channel.invokeMethod<void>('setRestrictedNumbers', <String, dynamic>{
      'numbers': numbers,
    });
  }
}
