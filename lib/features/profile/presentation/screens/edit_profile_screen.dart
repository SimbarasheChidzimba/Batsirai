import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/user.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  String? _lastUserId; // Track user ID to detect changes

  @override
  void initState() {
    super.initState();
    // Initialize controllers as empty - will be populated when user data is available
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Update controllers with user data (called when user is available or changes)
  void _updateControllersWithUserData(User user) {
    print('🔄 Updating controllers with user data:');
    print('   User ID: ${user.id}');
    print('   Last User ID: $_lastUserId');
    print('   DisplayName: ${user.displayName}');
    print('   Email: ${user.email}');
    print('   PhoneNumber: ${user.phoneNumber}');
    print('   Current nameController: ${_nameController.text}');
    print('   Current emailController: ${_emailController.text}');
    print('   Current phoneController: ${_phoneController.text}');
    
    // Always update if user ID changed, or if controllers are empty
    final shouldUpdate = _lastUserId != user.id ||
        _nameController.text.isEmpty ||
        _emailController.text.isEmpty;
    
    if (shouldUpdate) {
      print('✅ Updating controllers...');
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _lastUserId = user.id;
      print('   Updated nameController: ${_nameController.text}');
      print('   Updated emailController: ${_emailController.text}');
      print('   Updated phoneController: ${_phoneController.text}');
    } else {
      print('⏭️ Skipping update - controllers already have data');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement API call to update profile
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('Please sign in to edit your profile')),
      );
    }

    // Update controllers with user data when user is available
    _updateControllersWithUserData(user);

    // Get user initials
    String initials = 'U';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final names = user.displayName!.trim().split(' ');
      if (names.length >= 2) {
        initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names.isNotEmpty) {
        initials = names[0][0].toUpperCase();
      }
    } else if (user.email.isNotEmpty) {
      initials = user.email[0].toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null || user.photoUrl!.isEmpty
                            ? Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 20),
                            color: Colors.white,
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image upload coming soon!'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Implement image picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image upload coming soon!'),
                        ),
                      );
                    },
                    icon: PhosphorIcon(PhosphorIcons.camera()),
                    label: const Text('Change Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: PhosphorIcon(PhosphorIcons.user()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),

            // Email (read-only)
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: PhosphorIcon(PhosphorIcons.envelope()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: false,
                helperText: 'Email cannot be changed',
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: PhosphorIcon(PhosphorIcons.phone()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '+263 77 123 4567',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // Basic phone validation
                  if (!value.startsWith('+')) {
                    return 'Phone number should start with +';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.xl),

            // Membership Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.crownSimple(),
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          'Membership',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      user.membershipTierName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (user.membershipTier != MembershipTier.free &&
                        user.membershipExpiryDate != null) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Expires: ${_formatDate(user.membershipExpiryDate!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: Spacing.sm),
                    OutlinedButton(
                      onPressed: () => context.push('/membership'),
                      child: const Text('Manage Membership'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
