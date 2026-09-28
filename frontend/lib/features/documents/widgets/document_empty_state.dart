import 'package:flutter/material.dart';

/// DocumentEmptyState is displayed when no documents match the active category filter.
class DocumentEmptyState extends StatelessWidget {
  final String category;
  final VoidCallback? onResetFilter;

  const DocumentEmptyState({
    super.key,
    required this.category,
    this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              size: 26,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No $category Found',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'You have not added any documents in this category yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.0,
              color: Color(0xFF64748B),
            ),
          ),
          if (onResetFilter != null) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onResetFilter,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('View All Documents'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
