/// DocumentStatus defines the locked document verification states.
/// Defined in Team Development & Integration Playbook (Section 16).
enum DocumentStatus {
  pending('PENDING', 'Pending Verification'),
  verified('VERIFIED', 'Verified'),
  expired('EXPIRED', 'Expired'),
  rejected('REJECTED', 'Rejected');

  final String value;
  final String label;

  const DocumentStatus(this.value, this.label);

  static DocumentStatus fromString(String val) {
    return DocumentStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DocumentStatus.pending,
    );
  }
}
