import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/custom_button.dart';

class AddNozzleScreen extends StatefulWidget {
  const AddNozzleScreen({super.key});

  @override
  State<AddNozzleScreen> createState() => _AddNozzleScreenState();
}

class _AddNozzleScreenState extends State<AddNozzleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedTankId;
  List<Map<String, dynamic>> _tanks = [];
  bool _isLoading = false;
  bool _isLoadingTanks = true;

  @override
  void initState() {
    super.initState();
    _fetchTanks();
  }

  Future<void> _fetchTanks() async {
    try {
      final response = await Supabase.instance.client
          .from('tanks')
          .select('id, type, capacity')
          .order('created_at', ascending: true);
          
      setState(() {
        _tanks = List<Map<String, dynamic>>.from(response);
      });
      if (_tanks.isNotEmpty) {
        _selectedTankId = _tanks.first['id'] as String;
      }
    } catch (e) {
      debugPrint('Error fetching tanks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tanks: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingTanks = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addNozzle() async {
    if (!_formKey.currentState!.validate() || _selectedTankId == null) return;
    
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('nozzles').insert({
        'name': _nameController.text.trim(),
        'tank_id': _selectedTankId,
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nozzle registered successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Add Nozzle')),
      body: _isLoadingTanks
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_tanks.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'You must add a Fuel Tank before creating a Nozzle.',
                                      style: TextStyle(color: Colors.brown),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nozzle Name/Number',
                              hintText: 'e.g., Petrol Nozzle 1',
                              prefixIcon: Icon(Icons.local_gas_station_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Enter nozzle name' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedTankId,
                            decoration: const InputDecoration(
                              labelText: 'Connected Fuel Tank',
                              prefixIcon: Icon(Icons.storage_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            items: _tanks.map((tank) {
                              final type = tank['type'] ?? 'Unknown';
                              final capacity = tank['capacity']?.toString() ?? '0';
                              return DropdownMenuItem<String>(
                                value: tank['id'] as String,
                                child: Text('$type Tank ($capacity L)'),
                              );
                            }).toList(),
                            onChanged: _tanks.isEmpty
                                ? null
                                : (val) => setState(() => _selectedTankId = val!),
                            validator: (val) => val == null ? 'Select a tank' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'Create Nozzle',
                      onPressed: _isLoading || _tanks.isEmpty ? null : _addNozzle,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
