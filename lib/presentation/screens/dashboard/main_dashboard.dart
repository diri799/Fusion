import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class MainDashboard extends StatefulWidget {
  final Widget child;
  
  const MainDashboard({
    super.key,
    required this.child,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // ignore: unused_field
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final user = authProvider.currentUser!;
        final navigationItems = _getNavigationItems(user.role);
        
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: _buildBottomNavigationBar(navigationItems),
        );
      },
    );
  }
  
  List<NavigationItem> _getNavigationItems(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          NavigationItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/dashboard',
          ),
          NavigationItem(
            icon: Icons.event_outlined,
            activeIcon: Icons.event,
            label: 'Events',
            route: '/events',
          ),
          NavigationItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Users',
            route: '/users',
          ),
          NavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            route: '/profile',
          ),
        ];
        
      case UserRole.organizer:
        return [
          NavigationItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/dashboard',
          ),
          NavigationItem(
            icon: Icons.event_outlined,
            activeIcon: Icons.event,
            label: 'Events',
            route: '/events',
          ),
          NavigationItem(
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: 'Create',
            route: '/events/create',
          ),
          NavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            route: '/profile',
          ),
        ];
        
      default: // Student roles
        return [
          NavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            route: '/dashboard',
          ),
          NavigationItem(
            icon: Icons.event_outlined,
            activeIcon: Icons.event,
            label: 'Events',
            route: '/events',
          ),
          NavigationItem(
            icon: Icons.bookmark_outline,
            activeIcon: Icons.bookmark,
            label: 'Saved',
            route: '/bookmarks',
          ),
          NavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            route: '/profile',
          ),
        ];
    }
  }
  
  Widget _buildBottomNavigationBar(List<NavigationItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _isRouteSelected(item.route);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                  context.go(item.route);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected 
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  bool _isRouteSelected(String route) {
    final currentRoute = GoRouterState.of(context).uri.path;
    if (route == '/dashboard') {
      return currentRoute == '/dashboard';
    }
    return currentRoute.startsWith(route);
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  
  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}