import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/auth_repository.dart';
import '../../core/theme/app_theme.dart';

class AdminSignupScreen extends ConsumerStatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  ConsumerState<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends ConsumerState<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pumpNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pumpNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // Step 1: Create Supabase User with Email/Password
      final response = await authRepo.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        metadata: {
          'pump_name': _pumpNameController.text.trim(),
          'owner_name': _ownerNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'admin',
        },
      );

      final user = response.user;
      if (user != null) {
        // Step 2: Create local petrol pump record
        await authRepo.createPetrolPump(
          name: _pumpNameController.text.trim(),
          ownerId: user.id,
        );

        // Success -> Navigation would go here
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Pump Registration'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Launch your business',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your petrol pump in minutes',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Pump Name
              TextFormField(
                controller: _pumpNameController,
                decoration: const InputDecoration(
                  labelText: 'Pump Name',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Pump Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Owner Name
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Owner Name is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Phone is required' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (val) =>
                    val != null && val.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Register Pump'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
