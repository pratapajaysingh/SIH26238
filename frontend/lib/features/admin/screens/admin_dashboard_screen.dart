import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_overview_tab.dart';
import '../widgets/manual_review_tab.dart';
import '../widgets/unreached_beneficiaries_tab.dart';

/// AdminDashboardScreen serves as the central Ministry / Officer portal
/// for SIH-26238.
class AdminDashboardScreen extends StatefulWidget {
  final AuthController? authController;
  final AdminController? adminController;

  const AdminDashboardScreen({
    super.key,
    this.authController,
    this.adminController,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.adminController ??
        AdminController(adminRepository: ServiceLocator.instance.adminRepository);
    _controller.addListener(_onUpdate);
    _controller.loadAll();
  }

  @override
  void dispose() {
    if (widget.adminController == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onUpdate);
    }
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _handleLogout() async {
    final authCtrl = widget.authController ??
        AuthController(authRepository: ServiceLocator.instance.authRepository);
    await authCtrl.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Admin Header
            AdminHeader(onLogout: _handleLogout),

            // Tab bar selector
            _buildTabSelector(),

            // Notification / Banner alerts
            if (_controller.successMessage != null)
              _buildAlertBanner(_controller.successMessage!, const Color(0xFF059669), const Color(0xFFECFDF5)),
            if (_controller.errorMessage != null)
              _buildAlertBanner(_controller.errorMessage!, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),

            // Body Area
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF111827)))
                  : _buildActiveTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _controller.activeTabIndex,
        onTap: (index) => _controller.setActiveTab(index),
        selectedItemColor: const Color(0xFF111827),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule_folder_outlined),
            activeIcon: Icon(Icons.rule_folder),
            label: 'Manual Review',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search_outlined),
            activeIcon: Icon(Icons.person_search),
            label: 'Unreached ST',
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPillTab('Overview', 0),
          const SizedBox(width: 8),
          _buildPillTab(
            'Reviews (${_controller.manualReviews.where((r) => r.isOpen).length})',
            1,
          ),
          const SizedBox(width: 8),
          _buildPillTab(
            'Unreached (${_controller.dashboardData?.totalUnreached ?? 3})',
            2,
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab(String label, int index) {
    final isActive = _controller.activeTabIndex == index;
    return GestureDetector(
      onTap: () => _controller.setActiveTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner(String message, Color fg, Color bg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () => _controller.clearMessages(),
            child: Icon(Icons.close, size: 16, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_controller.activeTabIndex) {
      case 0:
        if (_controller.dashboardData == null) {
          return const Center(child: Text('Dashboard analytics unavailable.'));
        }
        return AdminOverviewTab(
          data: _controller.dashboardData!,
          onNavigateToReviews: () => _controller.setActiveTab(1),
          onNavigateToUnreached: () => _controller.setActiveTab(2),
        );
      case 1:
        return ManualReviewTab(controller: _controller);
      case 2:
        return UnreachedBeneficiariesTab(controller: _controller);
      default:
        return const SizedBox.shrink();
    }
  }
}
