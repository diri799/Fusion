import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/splash_screen.dart';
import '../../presentation/screens/dashboard/main_dashboard.dart';
import '../../presentation/screens/dashboard/student_dashboard.dart';
import '../../presentation/screens/dashboard/organizer_dashboard.dart';
import '../../presentation/screens/dashboard/admin_dashboard.dart';
import '../../presentation/screens/admin/users_screen.dart';
import '../../presentation/screens/events/event_list_screen.dart';
import '../../presentation/screens/events/event_detail_screen.dart';
import '../../presentation/screens/events/create_event_screen.dart';
import '../../presentation/screens/events/edit_event_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../data/models/event.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/notifications/notification_screen.dart';
import '../../presentation/screens/feedback/feedback_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/gallery/gallery_screen.dart';
import '../../presentation/screens/certificates/certificates_screen.dart';
import '../../presentation/screens/bookmarks/bookmarks_screen.dart';
import '../../presentation/screens/about/about_screen.dart';
import '../../presentation/screens/about/contact_screen.dart';
import '../../core/services/auth_service.dart';

class AppRouter {
  static final AuthService _authService = AuthService.instance;
  
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: _redirectLogic,
    routes: [
      // Splash and Onboarding Routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main Dashboard Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainDashboard(child: child),
        routes: [
          // Home/Dashboard Routes
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) {
              final user = _authService.currentUser;
              if (user == null) return const LoginScreen();
              
              switch (user.role.value) {
                case 'student_visitor':
                case 'student_participant':
                  return const StudentDashboard();
                case 'organizer':
                  return const OrganizerDashboard();
                case 'admin':
                  return const AdminDashboard();
                default:
                  return const StudentDashboard();
              }
            },
          ),
          
          // Events Routes
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventListScreen(),
            routes: [
              GoRoute(
                path: '/detail/:eventId',
                name: 'event-detail',
                builder: (context, state) => EventDetailScreen(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
              GoRoute(
                path: '/create',
                name: 'create-event',
                builder: (context, state) => const CreateEventScreen(),
              ),
              GoRoute(
                path: '/edit/:eventId',
                name: 'edit-event',
                builder: (context, state) => EditEventScreen(
                  eventId: state.pathParameters['eventId']!,
                ),
              ),
            ],
          ),
          
          // Profile Routes
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: '/edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
          
          // Other Main Routes
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/gallery',
            name: 'gallery',
            builder: (context, state) => const GalleryScreen(),
          ),
          GoRoute(
            path: '/certificates',
            name: 'certificates',
            builder: (context, state) => const CertificatesScreen(),
          ),
          GoRoute(
            path: '/bookmarks',
            name: 'bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
          GoRoute(
            path: '/users',
            name: 'users',
            builder: (context, state) => const UsersScreen(),
          ),
        ],
      ),
      
      // Standalone Routes (Outside Bottom Navigation)
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
  
  // Redirect logic based on authentication state
  static String? _redirectLogic(BuildContext context, GoRouterState state) {
    final isLoggedIn = _authService.isLoggedIn;
    final isGoingToAuth = state.matchedLocation.startsWith('/login') ||
                         state.matchedLocation.startsWith('/register') ||
                         state.matchedLocation.startsWith('/forgot-password');
    final isGoingToWelcome = state.matchedLocation == '/welcome';
    final isGoingToSplash = state.matchedLocation == '/splash';
    
    // Always allow splash screen
    if (isGoingToSplash) return null;
    
    // If not logged in
    if (!isLoggedIn) {
      // Allow auth screens and welcome screen
      if (isGoingToAuth || isGoingToWelcome) return null;
      // Redirect to welcome screen
      return '/welcome';
    }
    
    // If logged in
    if (isLoggedIn) {
      // Redirect auth screens to dashboard
      if (isGoingToAuth || isGoingToWelcome) return '/dashboard';
    }
    
    return null;
  }
}

// Route Names for easy access
class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String events = '/events';
  static const String eventDetail = '/events/detail';
  static const String createEvent = '/events/create';
  static const String editEvent = '/events/edit';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String gallery = '/gallery';
  static const String certificates = '/certificates';
  static const String bookmarks = '/bookmarks';
  static const String feedback = '/feedback';
  static const String about = '/about';
  static const String contact = '/contact';
}

// Navigation Extensions
extension AppNavigationExtension on BuildContext {
  // Navigation methods
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToDashboard() => go(AppRoutes.dashboard);
  void goToEvents() => go(AppRoutes.events);
  void goToProfile() => go(AppRoutes.profile);
  void goToNotifications() => go(AppRoutes.notifications);
  void goToSearch() => go(AppRoutes.search);
  void goToSettings() => go(AppRoutes.settings);
  void goToGallery() => go(AppRoutes.gallery);
  void goToCertificates() => go(AppRoutes.certificates);
  void goToBookmarks() => go(AppRoutes.bookmarks);
  void goToAbout() => go(AppRoutes.about);
  void goToContact() => go(AppRoutes.contact);
  
  // Event navigation
  void goToEventDetail(String eventId) => go('${AppRoutes.events}/detail/$eventId');
  void goToCreateEvent() => go('${AppRoutes.events}/create');
  void goToEditEvent(String eventId) => go('${AppRoutes.events}/edit/$eventId');
  void goToFeedback() => go(AppRoutes.feedback);
  
  // Push methods
  void pushLogin() => push(AppRoutes.login);
  void pushRegister() => push(AppRoutes.register);
  void pushEventDetail(String eventId) => push('${AppRoutes.events}/detail/$eventId');
  void pushEditProfile() => push('${AppRoutes.profile}/edit');
  
  // Pop methods
  void goBack() => pop();
  bool canPop() => canPop();
}

// Route Guards
class RouteGuards {
  static bool requiresAuth(String route) {
    const publicRoutes = [
      '/splash',
      '/welcome',
      '/login',
      '/register',
      '/forgot-password',
    ];
    return !publicRoutes.contains(route);
  }
  
  static bool requiresStudentParticipant(String route) {
    const studentParticipantRoutes = [
      '/certificates',
      '/events/detail', // For registration
    ];
    return studentParticipantRoutes.any((r) => route.startsWith(r));
  }
  
  static bool requiresOrganizer(String route) {
    const organizerRoutes = [
      '/events/create',
      '/events/edit',
    ];
    return organizerRoutes.any((r) => route.startsWith(r));
  }
  
  static bool requiresAdmin(String route) {
    const adminRoutes = [
      '/admin',
    ];
    return adminRoutes.any((r) => route.startsWith(r));
  }
}