import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/scholarship.dart';
import '../../../repositories/scholarship_repository.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';

/// ScholarshipDetailsScreen displays comprehensive scheme guidelines, eligibility overview,
/// and document requirements for a specific scholarship scheme.
/// Consumes GET /api/v1/scholarships/{schemeId}.
class ScholarshipDetailsScreen extends StatefulWidget {
  final String? schemeId;
  final Scholarship? initialScholarship;
  final ScholarshipRepository? repository;
  final String studentInitials;
  final int unreadNotificationsCount;

  const ScholarshipDetailsScreen({
    super.key,
    this.schemeId,
    this.initialScholarship,
    this.repository,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<ScholarshipDetailsScreen> createState() => _ScholarshipDetailsScreenState();
}

class _ScholarshipDetailsScreenState extends State<ScholarshipDetailsScreen> {
  late final ScholarshipRepository _repository;
  Scholarship? _scholarship;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ServiceLocator.instance.scholarshipRepository;
    _scholarship = widget.initialScholarship;

    if (_scholarship == null && widget.schemeId != null) {
      _loadScholarshipDetails(widget.schemeId!);
    }
  }

  Future<void> _loadScholarshipDetails(String schemeId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final scheme = await _repository.getScholarshipById(schemeId);
      if (mounted) {
        setState(() {
          _scholarship = scheme;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPatternWidth = screenWidth * 0.72;
    final topPatternHeight = topPatternWidth * (180 / 280);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top Decorative Tribal Curve
          Positioned(
            top: 0,
            right: 0,
            width: topPatternWidth,
            height: topPatternHeight,
            child: IgnorePointer(
              child: Image.asset(
                AssetConstants.topTribalPattern,
                fit: BoxFit.fill,
                alignment: Alignment.topRight,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Foreground Scrollable Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),

                  // Top Header
                  DashboardHeader(
                    initials: widget.studentInitials,
                    unreadNotificationsCount: widget.unreadNotificationsCount,
                    onNotificationTap: () => Navigator.of(context).pushNamed('/notifications'),
                    onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),

                  const SizedBox(height: 12),

                  // Page Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 2.0, right: 12.0),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 24,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scholarship Details',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Official scheme guidelines and eligibility criteria.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_isLoading) ...[
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF111827)),
                      ),
                    ),
                  ] else if (_errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFEF4444)),
                          const SizedBox(height: 10),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (widget.schemeId != null) {
                                _loadScholarshipDetails(widget.schemeId!);
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_scholarship != null) ...[
                    // Scheme Overview Hero Card
                    _buildOverviewCard(_scholarship!),

                    const SizedBox(height: 14),

                    // Scheme Guidelines & Benefits Card
                    _buildBenefitsCard(_scholarship!),

                    const SizedBox(height: 14),

                    // Document Requirements Card
                    _buildRequirementsCard(_scholarship!),

                    const SizedBox(height: 20),

                    // Primary Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/eligibility',
                                arguments: _scholarship,
                              );
                            },
                            icon: const Icon(Icons.verified_outlined, color: Colors.white, size: 18),
                            label: const Text(
                              'Check Eligibility',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/apply',
                                arguments: _scholarship,
                              );
                            },
                            icon: const Icon(Icons.edit_document, color: Color(0xFF0F172A), size: 18),
                            label: const Text(
                              'Proceed to Apply',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar with Scholarships Tab Active (Index 1)
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.of(context).maybePop();
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/applications');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/jago');
          }
        },
        onJagoTap: () => Navigator.of(context).pushNamed('/jago'),
      ),
    );
  }

  Widget _buildOverviewCard(Scholarship scheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.account_balance,
                  size: 26,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      scheme.ministry,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildMetricItem(Icons.currency_rupee_rounded, 'Benefit Amount', scheme.benefitAmount),
              _buildMetricItem(Icons.school_outlined, 'Level', scheme.educationLevel),
              _buildMetricItem(Icons.people_outline_rounded, 'Target Group', scheme.targetAudience),
              if (scheme.deadline.isNotEmpty)
                _buildMetricItem(Icons.calendar_today_outlined, 'Application Deadline', scheme.deadline),
              _buildMetricItem(Icons.cloud_outlined, 'Source Portal', scheme.sourcePortal),
              _buildMetricItem(Icons.verified_user_outlined, 'Source', scheme.source),
              _buildMetricItem(Icons.update_outlined, 'Last Updated', scheme.lastUpdated),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10.0, color: Color(0xFF94A3B8)),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBenefitsCard(Scholarship scheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheme Description & Benefits',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scheme.description,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF3B82F6)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Direct Benefit Transfer (DBT) is credited directly to Aadhaar-linked student accounts upon verification.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsCard(Scholarship scheme) {
    final docs = [
      'Aadhaar Card (Identity proof)',
      'Caste Certificate (ST / PVTG validation)',
      'Income Certificate (Tehsildar / Competent Authority)',
      'Previous Academic Mark Sheets',
      'Bank Account Proof (Aadhaar Seeded)',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Documents (Reusable from Wallet)',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ...docs.map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc,
                        style: const TextStyle(fontSize: 12.0, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
