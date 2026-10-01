import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/language_service.dart';
import '../../dashboard/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/widgets/dashboard_header.dart';
import '../controllers/jago_controller.dart';
import '../widgets/jago_ask_about_section.dart';
import '../widgets/jago_benefits_card.dart';
import '../widgets/jago_chat_bubble.dart';
import '../widgets/jago_intro_header.dart';
import '../widgets/jago_message_composer.dart';
import '../widgets/jago_suggestion_chips.dart';
import '../widgets/jago_typing_indicator.dart';

/// JagoScreen faithfully reproduces the JAGO AI Guide visual source of truth
/// matching the exact layout, colors, typography, and controls from the reference image.
class JagoScreen extends StatefulWidget {
  final JagoController? controller;
  final String studentInitials;
  final int unreadNotificationsCount;

  const JagoScreen({
    super.key,
    this.controller,
    this.studentInitials = 'AS',
    this.unreadNotificationsCount = 1,
  });

  @override
  State<JagoScreen> createState() => _JagoScreenState();
}

class _JagoScreenState extends State<JagoScreen> {
  late final JagoController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _currentNavIndex = 4; // Center JAGO tab active

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        JagoController(
          jagoRepository: ServiceLocator.instance.jagoRepository,
        );

    _controller.addListener(_onControllerUpdate);
    LanguageService.instance.addListener(_onGlobalLanguageChange);
    _controller.loadConversation();
  }

  void _onGlobalLanguageChange() {
    if (mounted && _controller.currentLanguage != LanguageService.instance.currentLanguage) {
      _controller.setLanguage(LanguageService.instance.currentLanguage);
    }
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onGlobalLanguageChange);
    _scrollController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onControllerUpdate);
    }
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleActionNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF111827),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final topPatternHeight = (screenHeight * 0.22).clamp(160.0, 220.0);
    final topPatternWidth = (screenWidth * 0.72).clamp(240.0, 360.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top Decorative Tribal Curve (Full Bleed to Top & Right Edges)
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

          // 2. Main Foreground Content Area
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Header: MoTA Emblem, TribalSetu Logo, Notification Bell, Profile Avatar
                DashboardHeader(
                  initials: widget.studentInitials,
                  unreadNotificationsCount: widget.unreadNotificationsCount,
                  onNotificationTap: () => Navigator.of(context).pushNamed('/notifications'),
                  onProfileTap: () => Navigator.of(context).pushNamed('/profile'),
                ),

                const SizedBox(height: 10),

                // Scrollable Chat & Shortcuts Area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meet JAGO Section
                        const JagoIntroHeader(),

                        const SizedBox(height: 12),

                        // Language Selector Pill (English / हिन्दी / Hinglish)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                              children: JagoController.supportedLanguages.map((lang) {
                                final isSelected = _controller.currentLanguage == lang['code'];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: GestureDetector(
                                    key: Key('lang_switch_${lang['code']}'),
                                    onTap: () => _controller.setLanguage(lang['code']!),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF111827) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(7.5),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.08),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        lang['name']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Benefits Strip (3 Items)
                        const JagoBenefitsCard(),

                        const SizedBox(height: 18),

                        // Date Separator Pill ("Today")
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Inline Error Banner if present
                        if (_controller.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _controller.errorMessage!,
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF991B1B)),
                                    ),
                                  ),
                                  if (_controller.lastSentMessage != null)
                                    TextButton(
                                      key: const Key('jago_retry_button'),
                                      onPressed: _controller.retryLastMessage,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        minimumSize: const Size(50, 28),
                                      ),
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFFDC2626),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Color(0xFF991B1B)),
                                    onPressed: _controller.clearError,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Chat Messages List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final msg in _controller.messages)
                                JagoChatBubble(message: msg),
                              if (_controller.isSending)
                                const JagoTypingIndicator(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Suggestion Chips (Horizontal)
                        JagoSuggestionChips(
                          chips: _controller.localizedSuggestionChips,
                          onChipSelected: (prompt) => _controller.sendMessage(prompt),
                        ),

                        const SizedBox(height: 18),

                        // "You can also ask about" Section (6 Cards)
                        JagoAskAboutSection(
                          options: _controller.localizedAskAboutOptions,
                          onPromptSelected: (prompt) => _controller.sendMessage(prompt),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Message Composer (Attachment + Input + Send Button)
                JagoMessageComposer(
                  isSending: _controller.isSending,
                  onSend: (text) => _controller.sendMessage(text),
                  onAttachment: () => _handleActionNotice('Attach documents from DigiLocker or storage'),
                ),
              ],
            ),
          ),
        ],
      ),

      // 3. Fixed Bottom Navigation Bar with Center JAGO Button Active
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentNavIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/scholarships');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/applications');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          } else if (index == 4) {
            _scrollToBottom();
          }
        },
        onJagoTap: () => _scrollToBottom(),
      ),
    );
  }
}
