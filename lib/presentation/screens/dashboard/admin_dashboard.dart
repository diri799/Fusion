import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fusion_fiesta_application_new/core/services/dashboard_service.dart';
import 'package:fusion_fiesta_application_new/presentation/widgets/common/custom_app_bar.dart';
import 'package:fusion_fiesta_application_new/presentation/widgets/common/stats_card.dart';
import 'package:fusion_fiesta_application_new/presentation/widgets/common/section_header.dart';
import 'package:fusion_fiesta_application_new/presentation/widgets/common/loading_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  AdminDashboardStats? _stats;
  List<PendingEvent> _pendingEvents = [];
  List<RecentActivity> _recentActivity = [];
  String? _errorMessage;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadDashboardData(silent: true);
      }
    });
  }
  
  Future<void> _loadDashboardData({bool silent = false}) async {
    if (!silent) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    }
    
    try {
      final dashboardService = DashboardService.instance;
      
      // Load all dashboard data in parallel
      final results = await Future.wait([
        dashboardService.getAdminStats(),
        dashboardService.getPendingEvents(),
        dashboardService.getRecentActivity(),
      ]);
      
      setState(() {
        _stats = results[0] as AdminDashboardStats;
        _pendingEvents = results[1] as List<PendingEvent>;
        _recentActivity = results[2] as List<RecentActivity>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (mounted && !silent) {
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
        title: 'Admin Dashboard',
        actions: [
          IconButton(
            onPressed: () => _loadDashboardData(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_stats?.pendingApprovals != null && _stats!.pendingApprovals > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _stats!.pendingApprovals > 9 ? '9+' : _stats!.pendingApprovals.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'system_settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('System Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'backup',
                child: ListTile(
                  leading: Icon(Icons.backup),
                  title: Text('Backup Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logs',
                child: ListTile(
                  leading: Icon(Icons.article),
                  title: Text('System Logs'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(),
                    const SizedBox(height: 24),
                    _buildMainStatsSection(),
                    const SizedBox(height: 24),
                    _buildSecondaryStatsSection(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildPendingApprovalsSection(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    _buildRecentActivitySection(),
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
  
  void _handleMenuAction(String value) {
    switch (value) {
      case 'system_settings':
        // TODO: Navigate to system settings
        break;
      case 'backup':
        _showBackupDialog();
        break;
      case 'logs':
        // TODO: Navigate to logs
        break;
    }
  }
  
  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Backup Data'),
          content: const Text('Are you sure you want to create a backup of all system data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement backup functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup created successfully')),
                );
              },
              child: const Text('Create Backup'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade600,
            Colors.indigo.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Overview',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'FusionFiesta Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat('Total Users', _stats?.totalUsers.toString() ?? '0'),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewStat('Total Events', _stats?.totalEvents.toString() ?? '0'),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewStat('This Month', _stats?.thisMonthEvents.toString() ?? '0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildMainStatsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Active Events',
                value: _stats?.activeEvents.toString() ?? '0',
                icon: Icons.event_available,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Pending Approvals',
                value: _stats?.pendingApprovals.toString() ?? '0',
                icon: Icons.pending_actions,
                color: Colors.orange,
                onTap: () => _showPendingApprovals(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total Registrations',
                value: _stats?.totalRegistrations.toString() ?? '0',
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Active Organizers',
                value: _stats?.activeOrganizers.toString() ?? '0',
                icon: Icons.verified_user,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSecondaryStatsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total Revenue',
                value: '\$${(_stats?.totalRevenue ?? 0.0).toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Media Files',
                value: _stats?.totalMedia.toString() ?? '0',
                icon: Icons.photo_library,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'System Health',
                value: '${_stats?.systemHealth ?? 0}%',
                icon: Icons.health_and_safety,
                color: (_stats?.systemHealth ?? 0) > 90 ? Colors.green : 
                      (_stats?.systemHealth ?? 0) > 70 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Storage Used',
                value: '${_stats?.storageUsed ?? 0}%',
                icon: Icons.storage,
                color: (_stats?.storageUsed ?? 0) > 80 ? Colors.red : 
                      (_stats?.storageUsed ?? 0) > 60 ? Colors.orange : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    final actions = [
      AdminAction(
        title: 'Approve Events',
        subtitle: '${_stats?.pendingApprovals ?? 0} pending',
        icon: Icons.approval,
        color: Colors.orange,
        onTap: () => _showPendingApprovals(),
        urgent: (_stats?.pendingApprovals ?? 0) > 0,
      ),
      AdminAction(
        title: 'Manage Users',
        subtitle: 'User administration',
        icon: Icons.people_outline,
        color: Colors.blue,
        onTap: () => context.go('/admin/users'),
      ),
      AdminAction(
        title: 'System Reports',
        subtitle: 'Analytics & insights',
        icon: Icons.analytics,
        color: Colors.green,
        onTap: () {
          // TODO: Navigate to reports
        },
      ),
      AdminAction(
        title: 'Platform Settings',
        subtitle: 'Configure system',
        icon: Icons.settings,
        color: Colors.purple,
        onTap: () => context.go('/settings'),
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Quick Actions',
          subtitle: 'Administrative tasks',
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: action.urgent 
                        ? action.color 
                        : action.color.withOpacity(0.3),
                    width: action.urgent ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: action.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 20,
                          ),
                        ),
                        if (action.urgent) ...[
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: action.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action.title,
                      style: TextStyle(
                        color: action.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        color: action.color.withOpacity(0.7),
                        fontSize: 11,
                      ),
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
  
  Widget _buildPendingApprovalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pending Approvals',
          subtitle: 'Events waiting for approval',
          actionText: 'View All',
          onActionTap: () => _showPendingApprovals(),
        ),
        const SizedBox(height: 16),
        if (_pendingEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All events are up to date! No pending approvals.',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pendingEvents.length > 3 ? 3 : _pendingEvents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildPendingEventCard(_pendingEvents[index]);
            },
          ),
      ],
    );
  }
  
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Recent Activity',
          subtitle: 'Latest platform activity',
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentActivity.length > 5 ? 5 : _recentActivity.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildActivityCard(_recentActivity[index]);
          },
        ),
      ],
    );
  }
  
  Widget _buildPendingEventCard(PendingEvent event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Organizer: ${event.organizerName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.email, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.organizerEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.category, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
          Text(
                event.categoryDisplayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                event.formattedPrice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.venue,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
          Text(
                '${event.startDate.day}/${event.startDate.month}/${event.startDate.year} ${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${event.registrationCount}/${event.maxParticipants}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectConfirmation(event),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showApproveConfirmation(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard(RecentActivity activity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getActivityTypeColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getActivityTypeIcon(activity.type),
              color: _getActivityTypeColor(activity.type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimeAgo(activity.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPendingApprovals() {
    // TODO: Navigate to dedicated pending approvals screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pending Approvals',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _pendingEvents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildPendingEventCard(_pendingEvents[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _approveEvent(PendingEvent event) async {
    try {
      final dashboardService = DashboardService.instance;
      await dashboardService.approveEvent(event.id);
      
      // Remove from pending events list
    setState(() {
        _pendingEvents.removeWhere((e) => e.id == event.id);
      });
      
      // Refresh dashboard data to get updated stats
      _loadDashboardData(silent: true);
      
      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${event.title}" approved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _rejectEvent(PendingEvent event) async {
    try {
      final dashboardService = DashboardService.instance;
      await dashboardService.rejectEvent(event.id);
      
      // Remove from pending events list
      setState(() {
        _pendingEvents.removeWhere((e) => e.id == event.id);
      });
      
      // Refresh dashboard data to get updated stats
      _loadDashboardData(silent: true);
      
      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${event.title}" rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject event: $e'),
        backgroundColor: Colors.red,
      ),
    );
      }
    }
  }

  void _showApproveConfirmation(PendingEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Event'),
        content: Text('Are you sure you want to approve "${event.title}"? This will make the event visible to all users.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _approveEvent(event);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
  
  void _showRejectConfirmation(PendingEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Event'),
        content: Text('Are you sure you want to reject "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _rejectEvent(event);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
  
  
  
  

  Color _getActivityTypeColor(String type) {
    switch (type) {
      case 'event_created':
        return Colors.blue;
      case 'registration':
        return Colors.green;
      case 'user_registration':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityTypeIcon(String type) {
    switch (type) {
      case 'event_created':
        return Icons.event;
      case 'registration':
        return Icons.person_add;
      case 'user_registration':
        return Icons.person;
      default:
        return Icons.info;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class AdminAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool urgent;
  
  AdminAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.urgent = false,
  });
}

class AdminStats {
  final int totalUsers;
  final int totalEvents;
  final int thisMonthEvents;
  final int activeEvents;
  final int pendingApprovals;
  final int totalRegistrations;
  final int activeOrganizers;
  final int certificatesIssued;
  final int mediaFiles;
  final int systemHealth;
  final int storageUsed;
  
  AdminStats({
    this.totalUsers = 0,
    this.totalEvents = 0,
    this.thisMonthEvents = 0,
    this.activeEvents = 0,
    this.pendingApprovals = 0,
    this.totalRegistrations = 0,
    this.activeOrganizers = 0,
    this.certificatesIssued = 0,
    this.mediaFiles = 0,
    this.systemHealth = 0,
    this.storageUsed = 0,
  });
  
  AdminStats copyWith({
    int? totalUsers,
    int? totalEvents,
    int? thisMonthEvents,
    int? activeEvents,
    int? pendingApprovals,
    int? totalRegistrations,
    int? activeOrganizers,
    int? certificatesIssued,
    int? mediaFiles,
    int? systemHealth,
    int? storageUsed,
  }) {
    return AdminStats(
      totalUsers: totalUsers ?? this.totalUsers,
      totalEvents: totalEvents ?? this.totalEvents,
      thisMonthEvents: thisMonthEvents ?? this.thisMonthEvents,
      activeEvents: activeEvents ?? this.activeEvents,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      totalRegistrations: totalRegistrations ?? this.totalRegistrations,
      activeOrganizers: activeOrganizers ?? this.activeOrganizers,
      certificatesIssued: certificatesIssued ?? this.certificatesIssued,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      systemHealth: systemHealth ?? this.systemHealth,
      storageUsed: storageUsed ?? this.storageUsed,
    );
  }
}

class PlatformActivity {
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  
  PlatformActivity({
    required this.description,
    required this.timestamp,
    required this.type,
  });
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

enum ActivityType {
  userRegistration(Icons.person_add, Colors.green),
  eventSubmission(Icons.event, Colors.blue),
  eventCompleted(Icons.check_circle, Colors.purple),
  userApproval(Icons.verified_user, Colors.orange),
  systemUpdate(Icons.system_update, Colors.grey);
  
  const ActivityType(this.icon, this.color);
  final IconData icon;
  final Color color;
}