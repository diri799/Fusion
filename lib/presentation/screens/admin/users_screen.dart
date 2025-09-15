import 'package:flutter/material.dart';
import 'package:fusion_fiesta_application_new/core/services/dashboard_service.dart';
import 'package:fusion_fiesta_application_new/data/models/admin_user.dart';
import 'package:fusion_fiesta_application_new/presentation/widgets/common/custom_app_bar.dart';
import 'package:fusion_fiesta_application_new/presentation/widgets/common/loading_widget.dart';
import 'package:fusion_fiesta_application_new/presentation/widgets/common/empty_state_widget.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _isLoading = true;
  List<AdminUser> _users = [];
  String _searchQuery = '';
  String? _selectedRole;
  bool? _selectedStatus;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _users.clear();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dashboardService = DashboardService.instance;
      final users = await dashboardService.getAllUsers(
        skip: _currentPage * _pageSize,
        limit: _pageSize,
        role: _selectedRole,
        isActive: _selectedStatus,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      setState(() {
        if (refresh) {
          _users = users;
        } else {
          _users.addAll(users);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'User Management',
        actions: [
          IconButton(
            onPressed: () => _loadUsers(refresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Users',
          ),
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Users',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading users...')
          : Column(
              children: [
                _buildSearchBar(),
                _buildStatsBar(),
                Expanded(
                  child: _users.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.people_outline,
                          title: 'No Users Found',
                          subtitle: 'No users match your current filters',
                        )
                      : _buildUsersList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchQuery == value) {
              _loadUsers(refresh: true);
            }
          });
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((user) => user.isActive).length;
    final verifiedUsers = _users.where((user) => user.isVerified).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalUsers, Colors.blue),
          _buildStatItem('Active', activeUsers, Colors.green),
          _buildStatItem('Verified', verifiedUsers, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    return RefreshIndicator(
      onRefresh: () => _loadUsers(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
          child: Icon(
            _getRoleIcon(user.role),
            color: _getRoleColor(user.role),
          ),
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.roleDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (user.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (user.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: user.isActive ? 'suspend' : 'activate',
              child: ListTile(
                leading: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  color: user.isActive ? Colors.orange : Colors.green,
                ),
                title: Text(user.isActive ? 'Suspend User' : 'Activate User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'role',
              child: ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Change Role'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'organizer':
        return Colors.purple;
      case 'student':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'organizer':
        return Icons.event_available;
      case 'student':
        return Icons.school;
      default:
        return Icons.person;
    }
  }

  void _handleUserAction(String action, AdminUser user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'suspend':
        _suspendUser(user);
        break;
      case 'activate':
        _activateUser(user);
        break;
      case 'role':
        _changeUserRole(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Username: ${user.username}'),
            Text('Role: ${user.roleDisplayName}'),
            Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
            Text('Verified: ${user.isVerified ? 'Yes' : 'No'}'),
            if (user.phone != null) Text('Phone: ${user.phone}'),
            Text('Joined: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
            if (user.lastLogin != null) 
              Text('Last Login: ${user.lastLogin!.day}/${user.lastLogin!.month}/${user.lastLogin!.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editUser(AdminUser user) {
    // TODO: Implement edit user functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit user: ${user.displayName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _suspendUser(AdminUser user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Are you sure you want to suspend ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final dashboardService = DashboardService.instance;
                await dashboardService.updateUserStatus(user.id, false);
                _loadUsers(refresh: true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.displayName} has been suspended'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to suspend user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  Future<void> _activateUser(AdminUser user) async {
    try {
      final dashboardService = DashboardService.instance;
      await dashboardService.updateUserStatus(user.id, true);
      _loadUsers(refresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.displayName} has been activated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to activate user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeUserRole(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current role: ${user.roleDisplayName}'),
            const SizedBox(height: 16),
            const Text('Select new role:'),
            const SizedBox(height: 8),
            ...['student', 'organizer', 'admin'].map((role) => ListTile(
              title: Text(_getRoleDisplayName(role)),
              leading: Radio<String>(
                value: role,
                groupValue: user.role,
                onChanged: (value) async {
                  Navigator.of(context).pop();
                  if (value != null && value != user.role) {
                    try {
                      final dashboardService = DashboardService.instance;
                      await dashboardService.updateUserRole(user.id, value);
                      _loadUsers(refresh: true);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${user.displayName}\'s role changed to ${_getRoleDisplayName(value)}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to change role: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'organizer':
        return 'Event Organizer';
      case 'student':
        return 'Student';
      default:
        return role.toUpperCase();
    }
  }

  void _deleteUser(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${user.displayName}?'),
            const SizedBox(height: 8),
            const Text(
              'Note: Users with events, registrations, or other data cannot be deleted. Consider suspending the user instead.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final dashboardService = DashboardService.instance;
                await dashboardService.deleteUser(user.id);
                _loadUsers(refresh: true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.displayName} has been deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  String errorMessage = 'Failed to delete user';
                  if (e.toString().contains('400')) {
                    errorMessage = 'Cannot delete user: User has associated data (events, registrations, etc.). Please suspend the user instead.';
                  } else if (e.toString().contains('Cannot delete your own account')) {
                    errorMessage = 'Cannot delete your own account';
                  } else {
                    errorMessage = 'Failed to delete user: $e';
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: const Text('All Users'),
              value: null,
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
                Navigator.of(context).pop();
                _loadUsers(refresh: true);
              },
            ),
            RadioListTile<String?>(
              title: const Text('Admins'),
              value: 'admin',
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
                Navigator.of(context).pop();
                _loadUsers(refresh: true);
              },
            ),
            RadioListTile<String?>(
              title: const Text('Organizers'),
              value: 'organizer',
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
                Navigator.of(context).pop();
                _loadUsers(refresh: true);
              },
            ),
            RadioListTile<String?>(
              title: const Text('Students'),
              value: 'student',
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
                Navigator.of(context).pop();
                _loadUsers(refresh: true);
              },
            ),
            const Divider(),
            RadioListTile<bool?>(
              title: const Text('All Status'),
              value: null,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                Navigator.of(context).pop();
                _loadUsers(refresh: true);
              },
            ),
            RadioListTile<bool?>(
              title: const Text('Active Only'),
              value: true,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                Navigator.of(context).pop();
                _loadUsers(refresh: true);
              },
            ),
            RadioListTile<bool?>(
              title: const Text('Inactive Only'),
              value: false,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                Navigator.of(context).pop();
                _loadUsers(refresh: true);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

}

