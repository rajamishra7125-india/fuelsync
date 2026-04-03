import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import 'controllers/sales_controller.dart';

class AddSaleScreen extends ConsumerStatefulWidget {
  const AddSaleScreen({super.key});

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final _amountController = TextEditingController();
  final _litresController = TextEditingController();
  String _selectedPaymentMode = 'Cash';
  File? _proofImage;

  final List<String> _paymentModes = ['Cash', 'UPI', 'Card', 'Credit'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() => _proofImage = File(image.path));
    }
  }

  Future<void> _handleSaveSale() async {
    if (_amountController.text.isEmpty || _litresController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount and litres')),
      );
      return;
    }

    final isSynced = await ref
        .read(salesControllerProvider.notifier)
        .saveSale(
          nozzleId: 'nozzle_01', // Mock for now
          amount: double.tryParse(_amountController.text) ?? 0.0,
          litres: double.tryParse(_litresController.text) ?? 0.0,
          paymentType: _selectedPaymentMode,
          proofImage: _proofImage,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSynced ? 'Sale synced successfully!' : 'Sale saved offline!',
          ),
          backgroundColor: isSynced ? AppTheme.successGreen : Colors.amber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(salesControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('New Sale Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NozzleHeader(),
            const SizedBox(height: 32),
            _buildInputFields(),
            const SizedBox(height: 32),
            _PaymentSelector(
              modes: _paymentModes,
              selected: _selectedPaymentMode,
              onSelected: (mode) => setState(() => _selectedPaymentMode = mode),
            ),
            const SizedBox(height: 32),
            _CameraProofPicker(image: _proofImage, onTap: _pickImage),
            const SizedBox(height: 48),
            CustomButton(
              label: 'Record Transaction',
              onPressed: _handleSaveSale,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'Total Amount (₹)',
            prefixIcon: const Icon(Icons.currency_rupee),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _litresController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'Total Litres (L)',
            prefixIcon: const Icon(Icons.local_gas_station),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

class _NozzleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gas_meter, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nozzle #01',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Petrol (E5) • Tank A',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('Change')),
        ],
      ),
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  final List<String> modes;
  final String selected;
  final Function(String) onSelected;

  const _PaymentSelector({
    required this.modes,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: modes.map((mode) {
            final isSelected = selected == mode;
            return InkWell(
              onTap: () => onSelected(mode),
              child: Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    mode,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CameraProofPicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const _CameraProofPicker({this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Camera Proof (Reading)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade200,
                style: BorderStyle.solid,
              ),
            ),
            child: image == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_enhance_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap to take photo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(image!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }
}
