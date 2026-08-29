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

  Future<void> setBlockingPolicy({
    required bool blockUnknownCallers,
    required bool rejectAllCalls,
    required bool allowOnlySelected,
    required List<String> allowedNumbers,
  }) async {
    await _channel.invokeMethod<void>('setBlockingPolicy', <String, dynamic>{
      'blockUnknownCallers': blockUnknownCallers,
      'rejectAllCalls': rejectAllCalls,
      'allowOnlySelected': allowOnlySelected,
      'allowedNumbers': allowedNumbers,
    });
  }

  Future<List<Map<String, dynamic>>> getRejectedCalls() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getRejectedCalls',
    );

    if (result == null) {
      return [];
    }

    return result
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> clearRejectedCalls() =>
      _channel.invokeMethod<void>('clearRejectedCalls');
}
