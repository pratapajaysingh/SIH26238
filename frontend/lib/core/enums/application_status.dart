/// ApplicationStatus defines the locked lifecycle statuses for scholarship applications.
/// Defined in Team Development & Integration Playbook (Section 16).
enum ApplicationStatus {
  draft('DRAFT', 'Draft'),
  submitted('SUBMITTED', 'Submitted'),
  inVerification('IN_VERIFICATION', 'In Verification'),
  deficiency('DEFICIENCY', 'Deficiency Pending'),
  sanctioned('SANCTIONED', 'Sanctioned'),
  rejected('REJECTED', 'Rejected'),
  withdrawn('WITHDRAWN', 'Withdrawn'),
  completed('COMPLETED', 'Completed');

  final String value;
  final String label;

  const ApplicationStatus(this.value, this.label);

  static ApplicationStatus fromString(String val) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => ApplicationStatus.draft,
    );
  }
}
