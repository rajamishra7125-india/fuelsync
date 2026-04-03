import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NozzleReportScreen extends StatefulWidget {
  const NozzleReportScreen({super.key});

  @override
  State<NozzleReportScreen> createState() => _NozzleReportScreenState();
}

class _NozzleReportScreenState extends State<NozzleReportScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _nozzleStats = [];

  @override
  void initState() {
    super.initState();
    _fetchNozzleStats();
  }

  Future<void> _fetchNozzleStats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch all nozzles
      final nozzlesResponse = await _supabase.from('nozzles').select('id, name');
      final nozzles = List<Map<String, dynamic>>.from(nozzlesResponse);

      // Fetch all sales directly joining nozzles is possible, 
      // but let's just fetch all sales and aggregate locally for today
      
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      final salesResponse = await _supabase
          .from('sales')
          .select('nozzle_id, amount, litres')
          .gte('created_at', '${todayStr}T00:00:00')
          .lt('created_at', '${todayStr}T23:59:59');
          
      final sales = List<Map<String, dynamic>>.from(salesResponse);

      Map<String, Map<String, dynamic>> stats = {};
      for (var n in nozzles) {
        stats[n['id']] = {
          'name': n['name'],
          'total_amount': 0.0,
          'total_litres': 0.0,
          'transaction_count': 0,
        };
      }

      for (var s in sales) {
        final nid = s['nozzle_id'] as String?;
        if (nid != null && stats.containsKey(nid)) {
          stats[nid]!['total_amount'] += (s['amount'] as num).toDouble();
          stats[nid]!['total_litres'] += (s['litres'] as num).toDouble();
          stats[nid]!['transaction_count'] = (stats[nid]!['transaction_count'] as int) + 1;
        }
      }

      setState(() {
        _nozzleStats = stats.values.toList()
          ..sort((a, b) => b['total_amount'].compareTo(a['total_amount']));
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
        title: const Text('Nozzle Summary (Today)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _nozzleStats.isEmpty
                  ? const Center(child: Text('No nozzles found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _nozzleStats.length,
                      itemBuilder: (context, index) {
                        final stat = _nozzleStats[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.local_gas_station, color: AppTheme.primaryColor),
                                    const SizedBox(width: 8),
                                    Text(stat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatCol('₹${(stat["total_amount"] as double).toStringAsFixed(2)}', 'Total Sales'),
                                    _buildStatCol('${(stat["total_litres"] as double).toStringAsFixed(2)} L', 'Volume'),
                                    _buildStatCol('${stat["transaction_count"]}', 'Transactions'),
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

  Widget _buildStatCol(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}
