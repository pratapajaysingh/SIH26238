/// VerificationStatus defines the locked verification state vocabulary.
/// Defined in Team Development & Integration Playbook (Section 16).
enum VerificationStatus {
  pending('PENDING', 'Pending'),
  verified('VERIFIED', 'Verified'),
  mismatch('MISMATCH', 'Mismatch Flagged'),
  manualReview('MANUAL_REVIEW', 'Manual Review'),
  failed('FAILED', 'Failed');

  final String value;
  final String label;

  const VerificationStatus(this.value, this.label);

  static VerificationStatus fromString(String val) {
    return VerificationStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => VerificationStatus.pending,
    );
  }
}
