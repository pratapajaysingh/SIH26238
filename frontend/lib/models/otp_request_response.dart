/// OtpRequestResponse models the response from POST /api/v1/auth/otp/request.
class OtpRequestResponse {
  final String detail;
  final int expiresIn;

  const OtpRequestResponse({
    required this.detail,
    required this.expiresIn,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      detail: json['detail'] as String? ?? 'If that address is valid, a code has been sent.',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 300,
    );
  }

  Map<String, dynamic> toJson() => {
    'detail': detail,
    'expires_in': expiresIn,
  };
}
