import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreditReportScreen extends StatefulWidget {
  const CreditReportScreen({super.key});

  @override
  State<CreditReportScreen> createState() => _CreditReportScreenState();
}

class _CreditReportScreenState extends State<CreditReportScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _debtors = [];
  double _totalOutstanding = 0;

  @override
  void initState() {
    super.initState();
    _fetchDebtors();
  }

  Future<void> _fetchDebtors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _totalOutstanding = 0;
      });

      final response = await _supabase
          .from('khata_customers')
          .select('id, name, phone, balance')
          .gt('balance', 0)
          .order('balance', ascending: false);
      
      final data = List<Map<String, dynamic>>.from(response);
      
      double total = 0;
      for (var row in data) {
        total += (row['balance'] as num).toDouble();
      }

      setState(() {
        _debtors = data;
        _totalOutstanding = total;
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
        title: const Text('Outstanding Credit (Khata)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text('Total Outstanding Amount', style: TextStyle(color: AppTheme.dangerRed, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            '₹${_totalOutstanding.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.dangerRed),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _debtors.isEmpty
                          ? const Center(child: Text('No outstanding balances!'))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _debtors.length,
                              separatorBuilder: (_, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final debtor = _debtors[index];
                                final name = debtor['name'] as String;
                                final phone = debtor['phone'] as String? ?? 'N/A';
                                final balance = (debtor['balance'] as num).toDouble();

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      child: Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                    ),
                                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    subtitle: Text('📞 $phone'),
                                    trailing: Text(
                                      '₹${balance.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.dangerRed),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
