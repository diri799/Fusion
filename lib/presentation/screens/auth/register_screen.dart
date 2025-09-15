import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _departmentController = TextEditingController();
  final _enrollmentController = TextEditingController();
  final _collegeIdController = TextEditingController();

  // State Variables
  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.studentVisitor;
  bool _acceptedTerms = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Business Administration',
    'Commerce',
    'Arts & Humanities',
    'Science',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _departmentController.dispose();
    _enrollmentController.dispose();
    _collegeIdController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_validateStep1()) {
        setState(() => _currentStep = 1);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _showErrorSnackBar('Please fill in all required fields correctly');
      }
    } else if (_currentStep == 1) {
      if (_validateStep2()) {
        setState(() => _currentStep = 2);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _showErrorSnackBar('Please enter your full name');
      }
    } else if (_currentStep == 2) {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateStep1() {
    // Check email
    if (_emailController.text.trim().isEmpty) {
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      return false;
    }
    
    // Check password
    if (_passwordController.text.isEmpty) {
      return false;
    }
    if (_passwordController.text.length < 8) {
      return false;
    }
    
    // Check password confirmation
    if (_confirmPasswordController.text.isEmpty) {
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return false;
    }
    
    return true;
  }

  bool _validateStep2() {
    // Check full name
    if (_fullNameController.text.trim().isEmpty) {
      return false;
    }
    if (_fullNameController.text.trim().length < 2) {
      return false;
    }
    if (_fullNameController.text.trim().split(' ').length < 2) {
      return false;
    }
    
    return true;
  }

  void _register() async {
    // Validate terms acceptance
    if (!_acceptedTerms) {
      _showErrorSnackBar('Please accept the terms and conditions to continue');
      return;
    }

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fix the errors above before continuing');
      return;
    }

    // Additional validation checks
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Email address is required');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Password is required');
      return;
    }

    if (_fullNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Full name is required');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match. Please check and try again');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        role: _selectedRole,
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileController.text.trim().isEmpty 
            ? null 
            : _mobileController.text.trim(),
        department: _departmentController.text.trim().isEmpty 
            ? null 
            : _departmentController.text.trim(),
        enrollmentNo: _enrollmentController.text.trim().isEmpty 
            ? null 
            : _enrollmentController.text.trim(),
        collegeId: _collegeIdController.text.trim().isEmpty 
            ? null 
            : _collegeIdController.text.trim(),
      );

      if (success) {
        if (mounted) {
          _showSuccessSnackBar('Account created successfully! Welcome to FusionFiesta!');
          // Small delay to show success message before navigation
          await Future.delayed(const Duration(milliseconds: 1500));
          context.go('/dashboard');
        }
      } else {
        if (mounted) {
          _handleRegistrationError(authProvider.errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        _handleRegistrationError(e.toString());
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleRegistrationError(String? errorMessage) {
    String userFriendlyMessage;
    
    if (errorMessage == null || errorMessage.isEmpty) {
      userFriendlyMessage = 'Registration failed. Please try again.';
    } else if (errorMessage.contains('email') && errorMessage.contains('already')) {
      userFriendlyMessage = 'An account with this email already exists. Please use a different email or try logging in.';
    } else if (errorMessage.contains('username') && errorMessage.contains('already')) {
      userFriendlyMessage = 'This username is already taken. Please choose a different username.';
    } else if (errorMessage.contains('email') && errorMessage.contains('invalid')) {
      userFriendlyMessage = 'Please enter a valid email address.';
    } else if (errorMessage.contains('password') && errorMessage.contains('weak')) {
      userFriendlyMessage = 'Password is too weak. Please use a stronger password with uppercase, lowercase, and numbers.';
    } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      userFriendlyMessage = 'Network error. Please check your internet connection and try again.';
    } else if (errorMessage.contains('server') || errorMessage.contains('500')) {
      userFriendlyMessage = 'Server error. Please try again in a few moments.';
    } else if (errorMessage.contains('timeout')) {
      userFriendlyMessage = 'Request timed out. Please check your connection and try again.';
    } else if (errorMessage.contains('Field required')) {
      userFriendlyMessage = 'Please fill in all required fields correctly.';
    } else if (errorMessage.contains('validation')) {
      userFriendlyMessage = 'Please check your input and try again.';
    } else {
      // Show original message if it's user-friendly, otherwise show generic message
      userFriendlyMessage = errorMessage.length > 100 
          ? 'Registration failed. Please try again.' 
          : errorMessage;
    }
    
    _showErrorSnackBar(userFriendlyMessage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Form Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
              
              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.go('/welcome'),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Join the FusionFiesta community',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          // ignore: unused_local_variable
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your login credentials',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email address is required';
                }
                if (value.length < 5) {
                  return 'Email address is too short';
                }
                if (value.length > 254) {
                  return 'Email address is too long';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address (e.g., user@example.com)';
                }
                if (value.contains(' ')) {
                  return 'Email address cannot contain spaces';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                if (value.length > 128) {
                  return 'Password is too long (maximum 128 characters)';
                }
                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must contain at least one uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must contain at least one lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must contain at least one number';
                }
                if (value.contains(' ')) {
                  return 'Password cannot contain spaces';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match. Please check and try again';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about yourself',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Full Name Field
            TextFormField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter your full name',
                prefixIcon: Icon(
                  Icons.person_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Full name is required';
                }
                if (value.trim().length < 2) {
                  return 'Full name must be at least 2 characters long';
                }
                if (value.trim().length > 100) {
                  return 'Full name is too long (maximum 100 characters)';
                }
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                  return 'Full name can only contain letters and spaces';
                }
                if (value.trim().split(' ').length < 2) {
                  return 'Please enter your first and last name';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Mobile Number Field
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: 'Enter your mobile number',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // Remove all non-digit characters for validation
                  final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                  
                  if (digitsOnly.length < 10) {
                    return 'Mobile number must be at least 10 digits';
                  }
                  if (digitsOnly.length > 15) {
                    return 'Mobile number is too long (maximum 15 digits)';
                  }
                  if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(digitsOnly)) {
                    return 'Please enter a valid mobile number';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Department Dropdown
            DropdownButtonFormField<String>(
              value: _departmentController.text.isEmpty ? null : _departmentController.text,
              decoration: InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(
                  Icons.school_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              items: _departments.map((department) {
                return DropdownMenuItem(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (value) {
                _departmentController.text = value ?? '';
              },
            ),

            const SizedBox(height: 20),

            // Enrollment/College ID Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _enrollmentController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Enrollment No.',
                      hintText: 'Optional',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _collegeIdController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'College ID',
                      hintText: 'Optional',
                      prefixIcon: Icon(
                        Icons.card_membership_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Type',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your role in the platform',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection
              ..._buildRoleOptions(),

              const SizedBox(height: 24),

              // Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _acceptedTerms = !_acceptedTerms;
                        });
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: theme.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleOptions() {
    final theme = Theme.of(context);
    
    final roles = [
      {
        'role': UserRole.studentVisitor,
        'title': 'Student Visitor',
        'description': 'Browse and view events without registration',
        'icon': Icons.visibility_outlined,
      },
      {
        'role': UserRole.studentParticipant,
        'title': 'Student Participant',
        'description': 'Register for events and earn certificates',
        'icon': Icons.person_add_outlined,
      },
      {
        'role': UserRole.organizer,
        'title': 'Event Organizer',
        'description': 'Create and manage events',
        'icon': Icons.event_available_outlined,
      },
      {
        'role': UserRole.admin,
        'title': 'Administrator',
        'description': 'Manage platform and approve events',
        'icon': Icons.admin_panel_settings_outlined,
      },
    ];

    return roles.map((roleData) {
      final role = roleData['role'] as UserRole;
      final isSelected = _selectedRole == role;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedRole = role;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected 
                  ? theme.colorScheme.primary.withOpacity(0.05)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  roleData['icon'] as IconData,
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roleData['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleData['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNavigationButtons() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Back',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _currentStep < 2 ? 'Next' : 'Create Account',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}