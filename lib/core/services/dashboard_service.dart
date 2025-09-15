import 'dart:convert';
import 'api_service.dart';
import 'package:fusion_fiesta_application_new/data/models/admin_user.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  static DashboardService get instance => _instance;
  final ApiService _apiService = ApiService.instance;

  // Admin Dashboard Statistics
  Future<AdminDashboardStats> getAdminStats() async {
    try {
      final response = await _apiService.get('/dashboard/admin/stats');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AdminDashboardStats.fromJson(data);
      } else {
        throw Exception('Failed to load admin stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching admin stats: $e');
      rethrow;
    }
  }

  // Organizer Dashboard Statistics
  Future<OrganizerDashboardStats> getOrganizerStats() async {
    try {
      final response = await _apiService.get('/dashboard/organizer/stats');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrganizerDashboardStats.fromJson(data);
      } else {
        throw Exception('Failed to load organizer stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching organizer stats: $e');
      rethrow;
    }
  }

  // Student Dashboard Statistics
  Future<StudentDashboardStats> getStudentStats() async {
    try {
      final response = await _apiService.get('/dashboard/student/stats');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return StudentDashboardStats.fromJson(data);
      } else {
        throw Exception('Failed to load student stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student stats: $e');
      rethrow;
    }
  }

  // Pending Events for Admin
  Future<List<PendingEvent>> getPendingEvents({int skip = 0, int limit = 10}) async {
    try {
      final response = await _apiService.get('/dashboard/admin/pending-events?skip=$skip&limit=$limit');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventsData = data['events'] as List;
        return eventsData.map((event) => PendingEvent.fromJson(event)).toList();
      } else {
        throw Exception('Failed to load pending events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pending events: $e');
      rethrow;
    }
  }


  // Recent Activity
  Future<List<RecentActivity>> getRecentActivity({int limit = 10}) async {
    try {
      final response = await _apiService.get('/dashboard/recent-activity?limit=$limit');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((activity) => RecentActivity.fromJson(activity)).toList();
      } else {
        throw Exception('Failed to load recent activity: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recent activity: $e');
      rethrow;
    }
  }

  // Admin Event Management
  Future<Map<String, dynamic>> approveEvent(int eventId) async {
    try {
      final response = await _apiService.post('/dashboard/admin/events/$eventId/approve');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to approve event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error approving event: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectEvent(int eventId) async {
    try {
      final response = await _apiService.post('/dashboard/admin/events/$eventId/reject');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to reject event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error rejecting event: $e');
      rethrow;
    }
  }

  // Admin User Management
  Future<List<AdminUser>> getAllUsers({
    int skip = 0,
    int limit = 100,
    String? role,
    bool? isActive,
    String? search,
  }) async {
    try {
      String queryParams = '?skip=$skip&limit=$limit';
      if (role != null) queryParams += '&role=$role';
      if (isActive != null) queryParams += '&is_active=$isActive';
      if (search != null && search.isNotEmpty) queryParams += '&search=$search';
      
      final response = await _apiService.get('/users/admin/all$queryParams');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((user) => AdminUser.fromJson(user)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserRole(int userId, String newRole) async {
    try {
      final response = await _apiService.put('/users/admin/$userId/role', body: {'role': newRole});
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user role: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserStatus(int userId, bool isActive) async {
    try {
      final response = await _apiService.put('/users/admin/$userId/status', body: {'is_active': isActive});
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await _apiService.delete('/users/admin/$userId');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.get('/users/admin/stats');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user stats: $e');
      rethrow;
    }
  }
}

// Data Models
class AdminDashboardStats {
  final int totalUsers;
  final int activeUsers;
  final Map<String, int> usersByRole;
  final int totalEvents;
  final Map<String, int> eventsByStatus;
  final int thisMonthEvents;
  final int activeEvents;
  final int pendingApprovals;
  final int totalRegistrations;
  final int activeOrganizers;
  final double totalRevenue;
  final int totalMedia;
  final Map<String, int> recentActivity;
  final int systemHealth;
  final int storageUsed;

  AdminDashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.usersByRole,
    required this.totalEvents,
    required this.eventsByStatus,
    required this.thisMonthEvents,
    required this.activeEvents,
    required this.pendingApprovals,
    required this.totalRegistrations,
    required this.activeOrganizers,
    required this.totalRevenue,
    required this.totalMedia,
    required this.recentActivity,
    required this.systemHealth,
    required this.storageUsed,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      usersByRole: Map<String, int>.from(json['users_by_role'] ?? {}),
      totalEvents: json['total_events'] ?? 0,
      eventsByStatus: Map<String, int>.from(json['events_by_status'] ?? {}),
      thisMonthEvents: json['this_month_events'] ?? 0,
      activeEvents: json['active_events'] ?? 0,
      pendingApprovals: json['pending_approvals'] ?? 0,
      totalRegistrations: json['total_registrations'] ?? 0,
      activeOrganizers: json['active_organizers'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      totalMedia: json['total_media'] ?? 0,
      recentActivity: Map<String, int>.from(json['recent_activity'] ?? {}),
      systemHealth: json['system_health'] ?? 0,
      storageUsed: json['storage_used'] ?? 0,
    );
  }
}

class OrganizerDashboardStats {
  final int totalEvents;
  final int activeEvents;
  final int thisMonthEvents;
  final int totalRegistrations;
  final double revenue;

  OrganizerDashboardStats({
    required this.totalEvents,
    required this.activeEvents,
    required this.thisMonthEvents,
    required this.totalRegistrations,
    required this.revenue,
  });

  factory OrganizerDashboardStats.fromJson(Map<String, dynamic> json) {
    return OrganizerDashboardStats(
      totalEvents: json['total_events'] ?? 0,
      activeEvents: json['active_events'] ?? 0,
      thisMonthEvents: json['this_month_events'] ?? 0,
      totalRegistrations: json['total_registrations'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
    );
  }
}

class StudentDashboardStats {
  final int registeredEvents;
  final int attendedEvents;
  final int upcomingEvents;
  final int feedbackSubmissions;
  final int mediaUploads;
  final int bookmarks;

  StudentDashboardStats({
    required this.registeredEvents,
    required this.attendedEvents,
    required this.upcomingEvents,
    required this.feedbackSubmissions,
    required this.mediaUploads,
    required this.bookmarks,
  });

  factory StudentDashboardStats.fromJson(Map<String, dynamic> json) {
    return StudentDashboardStats(
      registeredEvents: json['registered_events'] ?? 0,
      attendedEvents: json['attended_events'] ?? 0,
      upcomingEvents: json['upcoming_events'] ?? 0,
      feedbackSubmissions: json['feedback_submissions'] ?? 0,
      mediaUploads: json['media_uploads'] ?? 0,
      bookmarks: json['bookmarks'] ?? 0,
    );
  }
}

class PendingEvent {
  final int id;
  final String title;
  final String description;
  final String category;
  final String status;
  final int organizerId;
  final String organizerName;
  final String organizerEmail;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? registrationDeadline;
  final String venue;
  final int maxParticipants;
  final double registrationFee;
  final bool isPaidEvent;
  final String currency;
  final String? requirements;
  final String? bannerImageUrl;
  final String? eventAgenda;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int registrationCount;

  PendingEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.organizerId,
    required this.organizerName,
    required this.organizerEmail,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    required this.venue,
    required this.maxParticipants,
    required this.registrationFee,
    required this.isPaidEvent,
    required this.currency,
    this.requirements,
    this.bannerImageUrl,
    this.eventAgenda,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    required this.registrationCount,
  });

  factory PendingEvent.fromJson(Map<String, dynamic> json) {
    return PendingEvent(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      organizerId: json['organizer_id'] ?? 0,
      organizerName: json['organizer_name'] ?? '',
      organizerEmail: json['organizer_email'] ?? '',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      registrationDeadline: json['registration_deadline'] != null 
          ? DateTime.parse(json['registration_deadline']) 
          : null,
      venue: json['venue'] ?? '',
      maxParticipants: json['max_participants'] ?? 0,
      registrationFee: (json['registration_fee'] ?? 0.0).toDouble(),
      isPaidEvent: json['is_paid_event'] ?? false,
      currency: json['currency'] ?? 'USD',
      requirements: json['requirements'],
      bannerImageUrl: json['banner_image_url'],
      eventAgenda: json['event_agenda'],
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      registrationCount: json['registration_count'] ?? 0,
    );
  }

  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'academic':
        return 'Academic';
      case 'cultural':
        return 'Cultural';
      case 'sports':
        return 'Sports';
      case 'technical':
        return 'Technical';
      case 'social':
        return 'Social';
      case 'workshop':
        return 'Workshop';
      case 'seminar':
        return 'Seminar';
      case 'conference':
        return 'Conference';
      case 'other':
        return 'Other';
      default:
        return category.toUpperCase();
    }
  }

  String get formattedPrice {
    if (!isPaidEvent) return 'Free';
    return '${currency} ${registrationFee.toStringAsFixed(2)}';
  }
}


class RecentActivity {
  final String type;
  final String description;
  final DateTime timestamp;
  final String user;

  RecentActivity({
    required this.type,
    required this.description,
    required this.timestamp,
    required this.user,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      user: json['user'] ?? '',
    );
  }
}

