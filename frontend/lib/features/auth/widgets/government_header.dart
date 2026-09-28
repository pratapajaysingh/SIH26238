import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/theme/app_colors.dart';

/// GovernmentHeader displays the Lion Capital emblem, "Government of India" header,
/// and the subtle outlined language pill selector.
class GovernmentHeader extends StatelessWidget {
  final VoidCallback? onLanguageTap;
  final String currentLanguage;

  const GovernmentHeader({
    super.key,
    this.onLanguageTap,
    this.currentLanguage = 'EN',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          // Government of India Emblem + Text asset
          Image.asset(
            AssetConstants.govtHeader,
            height: 46,
            fit: BoxFit.contain,
            semanticLabel: 'Government of India emblem and title',
            errorBuilder: (context, error, stackTrace) => Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.account_balance, size: 28, color: AppColors.black),
                SizedBox(width: 8),
                Text(
                  'Government\nof India',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Language Selector Pill (exact match to reference: outlined pill over dark curve)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLanguageTap ?? () => _showLanguageModal(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentLanguage,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.white,
      builder: (ctx) {
        final languages = [
          {'code': 'EN', 'name': 'English'},
          {'code': 'HI', 'name': 'हिन्दी (Hindi)'},
          {'code': 'OR', 'name': 'ଓଡ଼ିଆ (Odia)'},
          {'code': 'SAT', 'name': 'ᱥᱟᱱᱛᱟᱲᱤ (Santali)'},
          {'code': 'GON', 'name': 'गोण्डी (Gondi)'},
          {'code': 'BN', 'name': 'বাংলা (Bengali)'},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Language / भाषा चुनें',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                ...languages.map(
                  (lang) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: lang['code'] == currentLanguage
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: lang['code'] == currentLanguage
                        ? const Icon(Icons.check_circle, color: AppColors.black, size: 20)
                        : null,
                    onTap: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
