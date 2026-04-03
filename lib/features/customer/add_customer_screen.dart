import 'package:flutter/material.dart';
// import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _creditLimitController = TextEditingController();
  bool _isLoading = false;

  void _handleAddCustomer() {
    setState(() => _isLoading = true);
    // Logic to save customer in Supabase
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Customer added!')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _creditLimitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Credit Limit (₹)',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                helperText: 'Maximum credit allowed for this customer',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehicleController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number (Optional)',
                prefixIcon: Icon(Icons.local_shipping_outlined),
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              label: 'Add Customer',
              onPressed: _handleAddCustomer,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
