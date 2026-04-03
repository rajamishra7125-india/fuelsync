import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';

class CreditPaymentScreen extends StatefulWidget {
  const CreditPaymentScreen({super.key});

  @override
  State<CreditPaymentScreen> createState() => _CreditPaymentScreenState();
}

class _CreditPaymentScreenState extends State<CreditPaymentScreen> {
  final _amountController = TextEditingController();
  String _selectedMode = 'Cash';
  File? _proofImage;
  bool _isLoading = false;

  final List<String> _paymentModes = ['Cash', 'UPI', 'Cheque', 'Bank Transfer'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _proofImage = File(image.path));
    }
  }

  void _handleSavePayment() {
    setState(() => _isLoading = true);
    // Logic to save payment in Supabase and update customer balance
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment received successfully!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Search/Select
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Customer',
                prefixIcon: Icon(Icons.person_search_outlined),
              ),
              items: [
                'Rajesh Kumar',
                'Simran Cargo',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Amount (₹)',
                prefixIcon: Icon(Icons.currency_rupee_outlined),
              ),
            ),
            const SizedBox(height: 32),

            // Payment Mode
            Text(
              'Payment Mode',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _paymentModes.map((mode) {
                final isSelected = _selectedMode == mode;
                return ChoiceChip(
                  label: Text(mode),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedMode = mode),
                  selectedColor: AppTheme.accentColor.withValues(alpha: 0.1),
                  checkmarkColor: AppTheme.accentColor,
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Proof Image
            Text(
              'Payment Proof (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _proofImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Capture Receipt',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_proofImage!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 48),

            CustomButton(
              label: 'Add Payment',
              onPressed: _handleSavePayment,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
