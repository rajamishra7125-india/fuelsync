import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  bool _isShiftActive = false; // Mock state
  bool _isLoading = false;
  File? _cashPhoto;

  final _openingCashController = TextEditingController();
  final _closingCashController = TextEditingController();

  // Nozzle reading controllers for shift start
  final Map<String, TextEditingController> _nozzleOpeningControllers = {};
  final Map<String, TextEditingController> _nozzleClosingControllers = {};

  // Mock nozzle data - in production, fetch from database
  final List<Map<String, String>> _nozzles = [
    {'id': 'nozzle_1', 'name': 'Nozzle 1 (Petrol)', 'fuelType': 'Petrol'},
    {'id': 'nozzle_2', 'name': 'Nozzle 2 (Diesel)', 'fuelType': 'Diesel'},
    {'id': 'nozzle_3', 'name': 'Nozzle 3 (Petrol)', 'fuelType': 'Petrol'},
    {'id': 'nozzle_4', 'name': 'Nozzle 4 (Diesel)', 'fuelType': 'Diesel'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each nozzle
    for (final nozzle in _nozzles) {
      _nozzleOpeningControllers[nozzle['id']!] = TextEditingController();
      _nozzleClosingControllers[nozzle['id']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _openingCashController.dispose();
    _closingCashController.dispose();
    for (final controller in _nozzleOpeningControllers.values) {
      controller.dispose();
    }
    for (final controller in _nozzleClosingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Calculate total sales from nozzle readings
  double _calculateNozzleSales(String nozzleId) {
    final opening =
        double.tryParse(_nozzleOpeningControllers[nozzleId]?.text ?? '0') ?? 0;
    final closing =
        double.tryParse(_nozzleClosingControllers[nozzleId]?.text ?? '0') ?? 0;
    return closing - opening;
  }

  /// Get total sales across all nozzles
  double get _totalNozzleSales {
    double total = 0;
    for (final nozzle in _nozzles) {
      total += _calculateNozzleSales(nozzle['id']!);
    }
    return total;
  }

  Future<void> _pickCashPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _cashPhoto = File(image.path));
    }
  }

  void _handleToggleShift() {
    setState(() => _isLoading = true);
    // Logic to start/end shift in Supabase
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isShiftActive = !_isShiftActive;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isShiftActive ? 'Shift Started!' : 'Shift Ended!'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shift Control')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: _isShiftActive
                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isShiftActive
                      ? AppTheme.successGreen.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isShiftActive
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline,
                    color: _isShiftActive ? AppTheme.successGreen : Colors.grey,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isShiftActive ? 'Shift is Active' : 'Shift Inactive',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _isShiftActive
                            ? 'Started at 08:30 AM'
                            : 'No active shift',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (!_isShiftActive) ...[
              // Start Shift UI
              TextFormField(
                controller: _openingCashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Opening Cash (₹)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nozzle Meter Readings (Shift Start)',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._nozzles.map(
                (nozzle) => _buildNozzleInput(
                  label: nozzle['name']!,
                  controller: _nozzleOpeningControllers[nozzle['id']]!,
                  fuelType: nozzle['fuelType']!,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Start Shift',
                onPressed: _handleToggleShift,
                isLoading: _isLoading,
              ),
            ] else ...[
              // End Shift UI
              TextFormField(
                controller: _closingCashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Closing Cash Collected (₹)',
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cash Drawer Proof',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickCashPhoto,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _cashPhoto == null
                      ? const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.file(_cashPhoto!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nozzle Meter Readings (Shift End)',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._nozzles.map(
                (nozzle) => _buildNozzleInput(
                  label: '${nozzle['name']} (End)',
                  controller: _nozzleClosingControllers[nozzle['id']]!,
                  fuelType: nozzle['fuelType']!,
                ),
              ),
              const SizedBox(height: 24),
              // Sales Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Nozzle Sales:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹ ${_totalNozzleSales.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'End Shift & Generate Summary',
                onPressed: _handleToggleShift,
                isLoading: _isLoading,
                backgroundColor: AppTheme.dangerRed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildNozzleInput({
  required String label,
  required TextEditingController controller,
  required String fuelType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.gas_meter_outlined,
          color: fuelType == 'Petrol'
              ? AppTheme.fuelGold
              : AppTheme.primaryColor,
        ),
        suffixText: 'L',
      ),
    ),
  );
}
