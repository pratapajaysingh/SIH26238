/// AuthMethod defines the primary login methods on the student entry screen.
enum AuthMethod {
  mobile('MOBILE', 'Mobile Number'),
  aadhaar('AADHAAR', 'Aadhaar');

  final String code;
  final String label;

  const AuthMethod(this.code, this.label);
}
