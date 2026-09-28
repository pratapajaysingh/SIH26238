import 'dart:math' as math;
import 'package:flutter/material.dart';

/// JagoMessageComposer renders the bottom message input field, attachment button,
/// and black circular send button matching the reference design.
class JagoMessageComposer extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onAttachment;
  final bool isSending;

  const JagoMessageComposer({
    super.key,
    required this.onSend,
    this.onAttachment,
    this.isSending = false,
  });

  @override
  State<JagoMessageComposer> createState() => _JagoMessageComposerState();
}

class _JagoMessageComposerState extends State<JagoMessageComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            // Attachment Button
            GestureDetector(
              onTap: widget.onAttachment,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: const Icon(
                    Icons.attach_file_rounded,
                    color: Color(0xFF111827),
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Text Input Pill
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: -0.1,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Black Circular Send Button
            GestureDetector(
              onTap: _handleSend,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF111827),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.near_me_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
