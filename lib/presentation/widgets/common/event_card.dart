import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/event.dart';
import '../../../data/models/common.dart';
import '../../../core/utils/app_router.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool showRegistrationStatus;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showRegistrationStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Banner or Placeholder
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getCategoryGradient(event.category),
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder pattern
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.event,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Date overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFormattedDay(event.eventDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getFormattedMonth(event.eventDate),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            event.category,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getCategoryColor(
                              event.category,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          event.category.displayName,
                          style: TextStyle(
                            color: _getCategoryColor(event.category),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Event Info Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.schedule,
                          event.eventTime,
                          context,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.location_on,
                          event.venue ?? 'TBA',
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Participants info
                  if (event.maxParticipants != null &&
                      event.maxParticipants! > 0)
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: event.occupancyPercentage / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCategoryColor(event.category),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${event.currentParticipants}/${event.maxParticipants}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  // Registration status for student view
                  if (showRegistrationStatus) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            event.canRegister
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.registrationStatus,
                        style: TextStyle(
                          color: event.canRegister ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Color> _getCategoryGradient(EventCategory category) {
    switch (category) {
      case EventCategory.technical:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case EventCategory.cultural:
        return [Colors.purple.shade400, Colors.purple.shade600];
      case EventCategory.sports:
        return [Colors.green.shade400, Colors.green.shade600];
      case EventCategory.academic:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case EventCategory.social:
        return [Colors.pink.shade400, Colors.pink.shade600];
      case EventCategory.workshop:
        return [Colors.teal.shade400, Colors.teal.shade600];
      case EventCategory.seminar:
        return [Colors.indigo.shade400, Colors.indigo.shade600];
      case EventCategory.conference:
        return [Colors.amber.shade400, Colors.amber.shade600];
      case EventCategory.other:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.technical:
        return Colors.blue;
      case EventCategory.cultural:
        return Colors.purple;
      case EventCategory.sports:
        return Colors.green;
      case EventCategory.academic:
        return Colors.orange;
      case EventCategory.social:
        return Colors.pink;
      case EventCategory.workshop:
        return Colors.teal;
      case EventCategory.seminar:
        return Colors.indigo;
      case EventCategory.conference:
        return Colors.amber;
      case EventCategory.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(EventStatusEnum status) {
    switch (status) {
      case EventStatusEnum.draft:
        return Colors.grey;
      case EventStatusEnum.published:
        return Colors.blue;
      case EventStatusEnum.ongoing:
        return Colors.green;
      case EventStatusEnum.completed:
        return Colors.purple;
      case EventStatusEnum.cancelled:
        return Colors.red;
      case EventStatusEnum.pending:
        return Colors.orange;
      case EventStatusEnum.approved:
        return Colors.green;
      case EventStatusEnum.rejected:
        return Colors.red;
    }
  }

  String _getFormattedDay(DateTime date) {
    return date.day.toString().padLeft(2, '0');
  }

  String _getFormattedMonth(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }
}
