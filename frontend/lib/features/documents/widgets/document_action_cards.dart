import 'package:flutter/material.dart';

/// DocumentActionCards renders the 3 top quick action cards matching the reference image:
/// 1. Upload Document (Blue)
/// 2. Fetch from DigiLocker (Green)
/// 3. Supported Formats (Purple)
class DocumentActionCards extends StatelessWidget {
  final VoidCallback? onUploadTap;
  final VoidCallback? onDigiLockerTap;
  final VoidCallback? onFormatsTap;

  const DocumentActionCards({
    super.key,
    this.onUploadTap,
    this.onDigiLockerTap,
    this.onFormatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Upload Document
        Expanded(
          child: _ActionCardItem(
            backgroundColor: const Color(0xFFF0F7FF),
            borderColor: const Color(0xFFDBEAFE),
            iconBackgroundColor: const Color(0xFFDBEAFE),
            icon: Icons.file_upload_outlined,
            iconColor: const Color(0xFF1D4ED8),
            title: 'Upload Document',
            titleColor: const Color(0xFF1E3A8A),
            subtitle: 'Add a document\nfrom your device',
            onTap: onUploadTap,
          ),
        ),
        const SizedBox(width: 8),

        // 2. Fetch from DigiLocker
        Expanded(
          child: _ActionCardItem(
            backgroundColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFDCFCE7),
            iconBackgroundColor: const Color(0xFFDCFCE7),
            icon: Icons.cloud_outlined,
            iconColor: const Color(0xFF16A34A),
            title: 'Fetch from DigiLocker',
            titleColor: const Color(0xFF15803D),
            subtitle: 'Import documents\ndirectly from DigiLocker',
            onTap: onDigiLockerTap,
          ),
        ),
        const SizedBox(width: 8),

        // 3. Supported Formats
        Expanded(
          child: _ActionCardItem(
            backgroundColor: const Color(0xFFFAF5FF),
            borderColor: const Color(0xFFF3E8FF),
            iconBackgroundColor: const Color(0xFFF3E8FF),
            icon: Icons.note_add_outlined,
            iconColor: const Color(0xFF7E22CE),
            title: 'Supported Formats',
            titleColor: const Color(0xFF6B21A8),
            subtitle: 'PDF, JPG, PNG\n(Max 5 MB each)',
            onTap: onFormatsTap,
          ),
        ),
      ],
    );
  }
}

class _ActionCardItem extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionCardItem({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 124,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.8,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.0,
                  color: Color(0xFF64748B),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
