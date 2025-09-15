import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/profile/edit'),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const LoadingWidget(message: 'Loading profile...');
          }

          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildProfileDetails(user),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        _buildProfileAvatar(user),
        const SizedBox(height: 16),
        Text(
          _getDisplayName(user),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getRoleDisplayName(user.role),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailItem(Icons.email, 'Email', user.email),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.person, 'Name', _getDisplayName(user)),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.badge, 'Role', _getRoleDisplayName(user.role)),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.calendar_today, 'Joined', _formatDate(user.createdAt)),
          if (user.details?.department != null && user.details!.department!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailItem(Icons.school, 'Department', user.details!.department!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () => context.go('/profile/edit'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences and notifications',
          onTap: () => context.go('/settings'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () => context.go('/help'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: _showLogoutDialog,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Colors.red
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              print('Profile Screen: Sign out button pressed');
              Navigator.of(context).pop();
              
              try {
                await context.read<AuthProvider>().logout();
                print('Profile Screen: Logout completed, navigating to login');
                if (mounted) {
                  context.go('/login');
                }
              } catch (e) {
                print('Profile Screen: Logout failed: $e');
                // Still navigate to login even if logout fails
                if (mounted) {
                  context.go('/login');
                }
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.studentVisitor:
        return 'Student Visitor';
      case UserRole.studentParticipant:
        return 'Student Participant';
      case UserRole.organizer:
        return 'Event Organizer';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildProfileAvatar(User user) {
    // Debug: Print user data
    print('Profile Screen - User data:');
    print('  Email: ${user.email}');
    print('  User ID: ${user.userId}');
    print('  Role: ${user.role}');
    print('  Details: ${user.details}');
    print('  Full Name: ${user.details?.fullName}');
    print('  Profile Pic URL: ${user.details?.profilePicUrl}');
    
    // Check if user has a profile picture
    final profilePicUrl = user.details?.profilePicUrl;
    
    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      // Show profile picture if available
      return ClipOval(
        child: Image.network(
          profilePicUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to initials if image fails to load
            return _buildInitialsAvatar(user);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            // Show loading indicator while image loads
            return SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Show user initials
      return _buildInitialsAvatar(user);
    }
  }

  Widget _buildInitialsAvatar(User user) {
    final initials = _getUserInitials(user);
    final backgroundColor = _getInitialsBackgroundColor(user);
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  String _getUserInitials(User user) {
    // Try to get initials from full name first
    if (user.details?.fullName != null && user.details!.fullName.isNotEmpty) {
      final nameParts = user.details!.fullName.trim().split(' ');
      if (nameParts.length >= 2) {
        // First name + Last name initials
        return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
      } else if (nameParts.length == 1) {
        // Single name - take first two characters
        final name = nameParts[0];
        return name.length >= 2 
            ? '${name[0]}${name[1]}'.toUpperCase()
            : name[0].toUpperCase();
      }
    }
    
    // Fallback to email initials
    final email = user.email;
    if (email.isNotEmpty) {
      final emailParts = email.split('@')[0];
      if (emailParts.length >= 2) {
        return '${emailParts[0]}${emailParts[1]}'.toUpperCase();
      } else {
        return emailParts[0].toUpperCase();
      }
    }
    
    // Final fallback
    return 'U';
  }

  Color _getInitialsBackgroundColor(User user) {
    // Generate a consistent color based on user data
    final hash = user.email.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.deepOrange,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getDisplayName(User user) {
    print('_getDisplayName called with user: ${user.email}');
    print('  Details: ${user.details}');
    print('  Full Name: ${user.details?.fullName}');
    
    // Try to get full name first
    if (user.details?.fullName != null && user.details!.fullName.isNotEmpty) {
      print('  Using full name: ${user.details!.fullName}');
      return user.details!.fullName;
    }
    
    // Fallback to email username
    final email = user.email;
    if (email.isNotEmpty) {
      final emailUsername = email.split('@')[0];
      // Capitalize first letter and replace dots/underscores with spaces
      final formattedName = emailUsername
          .replaceAll('.', ' ')
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word.isNotEmpty 
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '')
          .join(' ');
      return formattedName.isNotEmpty ? formattedName : 'User';
    }
    
    // Final fallback
    return 'User';
  }
}