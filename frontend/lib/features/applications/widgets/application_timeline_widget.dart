import 'package:flutter/material.dart';
import '../../../models/application_timeline.dart';

/// ApplicationTimelineWidget renders the 4-step horizontal progress tracker
/// with milestone nodes (Completed, In Progress, Deficiency, Rejected, Pending),
/// connecting lines, stage names, and formatted dates.
class ApplicationTimelineWidget extends StatelessWidget {
  final List<ApplicationTimelineEvent> events;

  const ApplicationTimelineWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    // Default to 4 standard stages if fewer provided
    final count = events.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (index) {
        final event = events[index];
        final isFirst = index == 0;
        final isLast = index == count - 1;

        // Line color coming from previous node
        Color incomingLineColor = const Color(0xFFE5E7EB);
        if (!isFirst) {
          final prevEvent = events[index - 1];
          if (prevEvent.isCompleted) {
            incomingLineColor = const Color(0xFF111827);
          }
        }

        // Line color going to next node
        Color outgoingLineColor = const Color(0xFFE5E7EB);
        if (!isLast) {
          if (event.isCompleted) {
            outgoingLineColor = const Color(0xFF111827);
          }
        }

        final isPending = event.isPending;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Node + Connecting Horizontal Lines
              SizedBox(
                height: 16,
                child: Row(
                  children: [
                    // Incoming Line (Left)
                    Expanded(
                      child: isFirst
                          ? const SizedBox.shrink()
                          : Container(
                              height: 1.5,
                              color: incomingLineColor,
                            ),
                    ),

                    // Checkpoint Circle Node
                    _buildNode(event),

                    // Outgoing Line (Right)
                    Expanded(
                      child: isLast
                          ? const SizedBox.shrink()
                          : Container(
                              height: 1.5,
                              color: outgoingLineColor,
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              // 2. Stage Title
              SizedBox(
                height: 24,
                child: Text(
                  event.stage,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.0,
                    fontWeight: isPending ? FontWeight.w500 : FontWeight.w700,
                    color: isPending ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                    height: 1.15,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // 3. Stage Date or "-"
              Text(
                event.dateFormatted,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.0,
                  fontWeight: FontWeight.w400,
                  color: isPending ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNode(ApplicationTimelineEvent event) {
    if (event.isCompleted) {
      return Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 9.5,
          color: Colors.white,
        ),
      );
    } else if (event.isDeficiency) {
      return Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(
          color: Color(0xFFF59E0B),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          '!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      );
    } else if (event.isRejected) {
      return Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.close,
          size: 9,
          color: Colors.white,
        ),
      );
    } else if (event.isInProgress) {
      return Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      // Pending
      return Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
      );
    }
  }
}
