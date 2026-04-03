import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/admin_signup_screen.dart';
import 'features/auth/staff_login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Supabase, but don't crash if keys are missing
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase Initialization skipped or failed: $e');
  }

  runApp(const ProviderScope(child: FuelSyncApp()));
}

class FuelSyncApp extends StatelessWidget {
  const FuelSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuelSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const InitialCheckScreen(),
    );
  }
}

class InitialCheckScreen extends ConsumerWidget {
  const InitialCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = Supabase.instance.client.auth.currentSession;

    // For demonstration purposes, we'll allow visiting the onboarding if no session
    if (session == null) {
      return const OnboardingChooser();
    } else {
      return const DashboardScreen();
    }
  }
}

class OnboardingChooser extends StatelessWidget {
  const OnboardingChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_gas_station,
                size: 80,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'FuelSync',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Efficient Petrol Pump Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSignupScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Admin Registration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StaffLoginScreen()),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Staff PIN Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            // Demo Access Link
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
              child: Text(
                'Explore Demo Dashboard',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
