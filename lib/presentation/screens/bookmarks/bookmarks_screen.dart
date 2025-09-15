import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/event_card.dart';
import '../../../data/models/event.dart';
import '../../../data/models/common.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  bool _isLoading = false;
  List<Event> _bookmarkedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarkedEvents();
  }

  Future<void> _loadBookmarkedEvents() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _bookmarkedEvents = _getMockBookmarkedEvents();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bookmarks',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_bookmarkedEvents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllBookmarks,
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading bookmarks...')
          : _bookmarkedEvents.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.bookmark_border,
                  title: 'No Bookmarks Yet',
                  subtitle: 'Events you bookmark will appear here',
                  actionText: 'Browse Events',
                  onActionTap: () => context.go('/events'),
                )
              : _buildBookmarksList(),
    );
  }

  Widget _buildBookmarksList() {
    return RefreshIndicator(
      onRefresh: _loadBookmarkedEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookmarkedEvents.length,
        itemBuilder: (context, index) {
          final event = _bookmarkedEvents[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                EventCard(
                  event: event,
                  onTap: () => context.go('/events/detail/${event.eventId}'),
                  showRegistrationStatus: false,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.bookmark,
                        color: Colors.orange,
                        size: 20,
                      ),
                      onPressed: () => _removeBookmark(event),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _removeBookmark(Event event) {
    setState(() {
      _bookmarkedEvents.removeWhere((e) => e.eventId == event.eventId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${event.title} from bookmarks'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _bookmarkedEvents.add(event);
            });
          },
        ),
      ),
    );
  }

  void _clearAllBookmarks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks'),
        content: const Text('Are you sure you want to remove all bookmarked events?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _bookmarkedEvents.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All bookmarks cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  List<Event> _getMockBookmarkedEvents() {
    return [
      Event.create(
        id: 1,
        title: 'Tech Fest 2024',
        description: 'Annual technical festival showcasing innovation and creativity.',
        category: EventCategory.technical,
        status: EventStatus.published,
        organizerId: 1,
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5, hours: 8)),
        venue: 'Main Auditorium',
        maxParticipants: 100,
        department: 'Computer Science',
      ),
      Event.create(
        id: 2,
        title: 'Cultural Night',
        description: 'An evening filled with cultural performances and traditions.',
        category: EventCategory.cultural,
        status: EventStatus.published,
        organizerId: 2,
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 10, hours: 4)),
        venue: 'Cultural Center',
        maxParticipants: 200,
        department: 'Cultural Committee',
      ),
      Event.create(
        id: 3,
        title: 'Hackathon 2024',
        description: '48-hour coding marathon for innovative solutions.',
        category: EventCategory.technical,
        status: EventStatus.published,
        organizerId: 1,
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 17)),
        venue: 'Computer Lab',
        maxParticipants: 50,
        department: 'Computer Science',
      ),
    ];
  }
}