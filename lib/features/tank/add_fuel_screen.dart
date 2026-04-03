import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import 'controllers/tank_controller.dart';

class AddFuelScreen extends ConsumerStatefulWidget {
  const AddFuelScreen({super.key});

  @override
  ConsumerState<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends ConsumerState<AddFuelScreen> {
  final _supplierController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  File? _invoiceImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() => _invoiceImage = File(image.path));
    }
  }

  Future<void> _handleSavePurchase() async {
    if (_supplierController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final isSynced = await ref
        .read(tankControllerProvider.notifier)
        .recordPurchase(
          supplier: _supplierController.text,
          quantity: double.tryParse(_quantityController.text) ?? 0.0,
          rate: double.tryParse(_rateController.text) ?? 0.0,
          invoiceImage: _invoiceImage,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSynced
                ? 'Purchase recorded and synced!'
                : 'Purchase saved offline!',
          ),
          backgroundColor: isSynced ? AppTheme.successGreen : Colors.amber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(tankControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Record Stock Refill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildForm(),
            const SizedBox(height: 32),
            _ImagePickerSection(image: _invoiceImage, onTap: _pickImage),
            const SizedBox(height: 48),
            CustomButton(
              label: 'Update Tank Stock',
              onPressed: _handleSavePurchase,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          controller: _supplierController,
          decoration: InputDecoration(
            labelText: 'Supplier Name',
            prefixIcon: const Icon(Icons.business),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity (Litres)',
            prefixIcon: const Icon(Icons.local_gas_station),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _rateController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Purchase Rate (₹/L)',
            prefixIcon: const Icon(Icons.payments_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const _ImagePickerSection({this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invoice Photo / Delivery Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
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
                        Icons.add_a_photo_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Capture Invoice',
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
