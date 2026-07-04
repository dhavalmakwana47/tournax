import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_request_model.g.dart';

@JsonSerializable()
class VerifyOtpRequestModel {
  const VerifyOtpRequestModel({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toJson() => _$VerifyOtpRequestModelToJson(this);

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestModelFromJson(json);
}
