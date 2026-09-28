import 'package:flutter/material.dart';

/// ScholarshipsSearchBar renders the large rounded input field with search icon
/// matching the exact visual characteristics from the reference image.
class ScholarshipsSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String initialValue;

  const ScholarshipsSearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
    this.initialValue = '',
  });

  @override
  State<ScholarshipsSearchBar> createState() => _ScholarshipsSearchBarState();
}

class _ScholarshipsSearchBarState extends State<ScholarshipsSearchBar> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 14.0, right: 10.0),
              child: Icon(
                Icons.search_rounded,
                color: Color(0xFF111827),
                size: 20,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                onChanged: (val) {
                  setState(() {});
                  widget.onChanged(val);
                },
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
                decoration: const InputDecoration(
                  hintText: 'Search scholarships, schemes, or keywords...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.1,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_textController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _textController.clear();
                  widget.onChanged('');
                  widget.onClear?.call();
                  setState(() {});
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
