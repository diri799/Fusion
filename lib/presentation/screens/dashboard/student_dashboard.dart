import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_router.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../data/models/event.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/event_card.dart';
import '../../widgets/common/stats_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isLoading = true;
  List<Event> _upcomingEvents = [];
  List<Event> _registeredEvents = [];
  StudentDashboardStats? _stats;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final dashboardService = DashboardService.instance;
      // Load all data in parallel
      final results = await Future.wait([
        dashboardService.getStudentStats(),
      ]);
      
      setState(() {
        _stats = results[0] as StudentDashboardStats;
        _upcomingEvents = []; // TODO: Replace with real event service
        _registeredEvents = []; // TODO: Replace with real registration service
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getGreetingTitle(),
        actions: [
          IconButton(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: _isLoading 
          ? const LoadingWidget()
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildStatsSection(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    _buildRegisteredEventsSection(),
                    const SizedBox(height: 24),
                    _buildUpcomingEventsSection(),
                    const SizedBox(height: 100), // Bottom navigation padding
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getGreetingTitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
  
  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final displayName = user?.details?.fullName ?? 'Student';
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      authProvider.userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Discover amazing events happening at your college!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/events'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Explore Events'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Upcoming',
                value: _stats?.upcomingEvents.toString() ?? '0',
                icon: Icons.event,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Registered',
                value: _stats?.registeredEvents.toString() ?? '0',
                icon: Icons.event_available,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Attended',
                value: _stats?.attendedEvents.toString() ?? '0',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Bookmarks',
                value: _stats?.bookmarks.toString() ?? '0',
                icon: Icons.bookmark,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    final actions = [
      QuickAction(
        title: 'Browse Events',
        icon: Icons.explore,
        color: Colors.blue,
        onTap: () => context.go('/events'),
      ),
      QuickAction(
        title: 'My Bookmarks',
        icon: Icons.bookmark,
        color: Colors.purple,
        onTap: () => context.go('/bookmarks'),
      ),
      QuickAction(
        title: 'Gallery',
        icon: Icons.photo_library,
        color: Colors.green,
        onTap: () => context.go('/gallery'),
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Quick Actions',
          subtitle: 'What would you like to do?',
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: action.onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: action.color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action.icon,
                      color: action.color,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.title,
                      style: TextStyle(
                        color: action.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  

  Widget _buildRegisteredEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'My Registrations',
          subtitle: 'Events you\'re registered for',
          actionText: 'View All',
          onActionTap: () => context.go('/events?filter=registered'),
        ),
        const SizedBox(height: 16),
        if (_registeredEvents.isEmpty)
          const EmptyStateWidget(
            icon: Icons.event_available,
            title: 'No Registered Events',
            subtitle: 'Register for events to see them here',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _registeredEvents.length > 3 ? 3 : _registeredEvents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return EventCard(
                event: _registeredEvents[index],
                onTap: () => context.goToEventDetail(_registeredEvents[index].eventId),
              );
            },
          ),
      ],
    );
  }
  
  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming Events',
          subtitle: 'Don\'t miss these exciting events',
          actionText: 'View All',
          onActionTap: () => context.go('/events'),
        ),
        const SizedBox(height: 16),
        if (_upcomingEvents.isEmpty)
          const EmptyStateWidget(
            icon: Icons.event,
            title: 'No Upcoming Events',
            subtitle: 'Check back later for new events',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingEvents.length > 5 ? 5 : _upcomingEvents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return EventCard(
                event: _upcomingEvents[index],
                onTap: () => context.goToEventDetail(_upcomingEvents[index].eventId),
              );
            },
          ),
      ],
    );
  }
  
  
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class DashboardStats {
  final int registeredEvents;
  final int attendedEvents;
  final int bookmarks;
  
  DashboardStats({
    this.registeredEvents = 0,
    this.attendedEvents = 0,
    this.bookmarks = 0,
  });
}