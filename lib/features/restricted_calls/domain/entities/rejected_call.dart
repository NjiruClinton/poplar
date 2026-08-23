import 'package:freezed_annotation/freezed_annotation.dart';

part 'rejected_call.freezed.dart';
part 'rejected_call.g.dart';

@freezed
class RejectedCall with _$RejectedCall {
  const factory RejectedCall({
    required String phoneNumber,
    String? contactName,
    required DateTime timestamp,
  }) = _RejectedCall;

  factory RejectedCall.fromJson(Map<String, dynamic> json) =>
      _$RejectedCallFromJson(json);
}
