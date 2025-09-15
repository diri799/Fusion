import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/event_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../../data/models/event.dart';
import '../../../data/models/common.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  
  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    try {
      final eventProvider = context.read<EventProvider>();
      final event = await eventProvider.getEventById(widget.eventId);
      
      if (event != null) {
        setState(() {
          _event = event;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Event not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load event details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Event Details',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const LoadingWidget(message: 'Loading event details...'),
      );
    }

    if (_errorMessage != null || _event == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Event Details',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Event Not Found',
          subtitle: _errorMessage ?? 'The requested event could not be found',
          actionText: 'Go Back',
          onActionTap: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Event Details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildEventBanner(),
            _buildEventContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBanner() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getCategoryGradient(_event!.category),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.event,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_event!.status),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _event!.status.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _event!.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _event!.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
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

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.pending:
        return Colors.orange;
      case EventStatus.published:
        return Colors.green;
      case EventStatus.ongoing:
        return Colors.blue;
      case EventStatus.completed:
        return Colors.purple;
      case EventStatus.cancelled:
        return Colors.grey;
      case EventStatus.draft:
        return Colors.brown;
      case EventStatus.approved:
        return Colors.green;
      case EventStatus.rejected:
        return Colors.red;
    }
  }
}