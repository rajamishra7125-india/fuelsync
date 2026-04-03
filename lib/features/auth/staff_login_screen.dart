import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class StaffLoginScreen extends ConsumerStatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  ConsumerState<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends ConsumerState<StaffLoginScreen> {
  final _pinController = TextEditingController();
  final _userIdController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _handlePinLogin() async {
    if (_pinController.text.length < 4) return;

    // Logic to verify user in Supabase by User ID + PIN
    // Staff login logic

    await Future.delayed(const Duration(seconds: 1)); // Mock

    if (mounted) {
      // Navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Login'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_outlined,
                size: 60,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Enter your PIN',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select account and enter 4-digit PIN',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),

            // User Selection placeholder
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: AppTheme.softShadow,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select Operator'),
                  items: ['John (Operator)', 'Sarah (Manager)']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {},
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Custom PIN Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pinController.text.length > index
                          ? AppTheme.accentColor
                          : Colors.grey.shade200,
                      width: 2,
                    ),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Center(
                    child: Text(
                      _pinController.text.length > index ? '*' : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),

            // Number Pad
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) return const SizedBox.shrink();
                  if (index == 11) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_pinController.text.isNotEmpty) {
                            setState(
                              () => _pinController.text = _pinController.text
                                  .substring(0, _pinController.text.length - 1),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Center(
                          child: Icon(Icons.backspace_outlined),
                        ),
                      ),
                    );
                  }
                  final number = index == 10 ? 0 : index + 1;
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 0,
                    child: InkWell(
                      onTap: () {
                        if (_pinController.text.length < 4) {
                          setState(
                            () => _pinController.text += number.toString(),
                          );
                          if (_pinController.text.length == 4) {
                            _handlePinLogin();
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          number.toString(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
