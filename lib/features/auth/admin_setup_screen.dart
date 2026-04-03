import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class AdminSetupScreen extends ConsumerStatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  ConsumerState<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends ConsumerState<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _tankCapacityController = TextEditingController();

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG'];
  final List<String> _selectedFuelTypes = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _gstController.dispose();
    _tankCapacityController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFuelTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one fuel type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Logic to update petrol_pumps record
      // And maybe initialize tanks based on fuel types

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Setup completed!')));
        // Navigate to Dashboard
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
      appBar: AppBar(title: const Text('Pump Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete your profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Pump Address',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.location_on_outlined),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),

              // GST Number
              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(
                  labelText: 'GST Number',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Fuel Types Selection
              Text(
                'Select Fuel Types',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _fuelTypes.map((type) {
                  final isSelected = _selectedFuelTypes.contains(type);
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFuelTypes.add(type);
                        } else {
                          _selectedFuelTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.accentColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Tank Capacity
              TextFormField(
                controller: _tankCapacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Tank Capacity (Litres per tank)',
                  prefixIcon: Icon(Icons.storage_outlined),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Capacity is required' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSetup,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Complete Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
