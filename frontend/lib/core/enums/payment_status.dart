/// PaymentStatus defines the locked DBT and sanction payment state vocabulary.
/// Defined in Team Development & Integration Playbook (Section 16).
enum PaymentStatus {
  sanctioned('SANCTIONED', 'Sanctioned'),
  dbtInitiated('DBT_INITIATED', 'DBT Initiated'),
  processing('PROCESSING', 'Processing'),
  credited('CREDITED', 'Credited to Bank Account'),
  failed('FAILED', 'Payment Failed');

  final String value;
  final String label;

  const PaymentStatus(this.value, this.label);

  static PaymentStatus fromString(String val) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => PaymentStatus.processing,
    );
  }
}
