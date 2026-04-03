import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _tanks = [];

  @override
  void initState() {
    super.initState();
    _fetchStock();
  }

  Future<void> _fetchStock() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _supabase.from('tanks').select('id, type, capacity, current_stock').order('type', ascending: true);
      
      setState(() {
        _tanks = List<Map<String, dynamic>>.from(response);
      });

    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Live Stock Report'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _tanks.isEmpty
                  ? const Center(child: Text('No tanks configured.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tanks.length,
                      itemBuilder: (context, index) {
                        final tank = _tanks[index];
                        final type = tank['type'] as String;
                        final capacity = (tank['capacity'] as num).toDouble();
                        final currentStock = (tank['current_stock'] as num).toDouble();
                        
                        final double percentage = capacity > 0 ? (currentStock / capacity) : 0;
                        
                        Color fill = Colors.green;
                        if (percentage < 0.2) {
                          fill = Colors.red;
                        } else if (percentage < 0.5) {
                          fill = Colors.orange;
                        }

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$type Tank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    Text('\${(percentage * 100).toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: fill, fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: percentage.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.shade200,
                                  color: fill,
                                  minHeight: 12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildLabel('Current Stock', '\${currentStock.toStringAsFixed(2)} L', fill),
                                    _buildLabel('Total Capacity', '\${capacity.toStringAsFixed(0)} L', Colors.black87),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildLabel(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}
