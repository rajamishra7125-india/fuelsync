import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ShiftHistoryScreen extends StatefulWidget {
  const ShiftHistoryScreen({super.key});

  @override
  State<ShiftHistoryScreen> createState() => _ShiftHistoryScreenState();
}

class _ShiftHistoryScreenState extends State<ShiftHistoryScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _shifts = [];

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  Future<void> _fetchShifts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Join user_profiles to get the operator's name
      final response = await _supabase
          .from('shifts')
          .select('id, status, start_time, end_time, user_profiles(name)')
          .order('start_time', ascending: false)
          .limit(30);
      
      setState(() {
        _shifts = List<Map<String, dynamic>>.from(response);
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
        title: const Text('Recent Shifts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _shifts.isEmpty
                  ? const Center(child: Text('No shift records found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _shifts.length,
                      itemBuilder: (context, index) {
                        final shift = _shifts[index];
                        final status = shift['status'] as String? ?? 'Open';
                        final userInfo = shift['user_profiles'] as Map<String, dynamic>?;
                        final operatorName = userInfo?['name'] as String? ?? 'Unknown Operator';
                        
                        final startDt = DateTime.parse(shift['start_time']).toLocal();
                        final startStr = DateFormat('MMM d, h:mm a').format(startDt);
                        
                        String endStr = 'In Progress';
                        if (shift['end_time'] != null) {
                          final endDt = DateTime.parse(shift['end_time']).toLocal();
                          endStr = DateFormat('MMM d, h:mm a').format(endDt);
                        }

                        final isOpen = status.toLowerCase() == 'open';

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: isOpen ? Colors.green.shade200 : Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isOpen ? Icons.play_circle_fill : Icons.stop_circle,
                                          color: isOpen ? Colors.green : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Status: $status', style: TextStyle(fontWeight: FontWeight.bold, color: isOpen ? Colors.green : Colors.grey)),
                                      ],
                                    ),
                                    Text(operatorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTimeCol('Started At', startStr, Icons.login),
                                    _buildTimeCol('Closed At', endStr, Icons.logout),
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

  Widget _buildTimeCol(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
