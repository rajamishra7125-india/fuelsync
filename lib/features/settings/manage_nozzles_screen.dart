import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_nozzle_screen.dart';

class ManageNozzlesScreen extends StatefulWidget {
  const ManageNozzlesScreen({super.key});

  @override
  State<ManageNozzlesScreen> createState() => _ManageNozzlesScreenState();
}

class _ManageNozzlesScreenState extends State<ManageNozzlesScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _nozzlesList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNozzles();
  }

  Future<void> _fetchNozzles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      // Fetch nozzles and join tanks for tank type display
      final response = await _supabase
          .from('nozzles')
          .select('id, name, created_at, tanks(type, capacity)')
          .order('name', ascending: true);
          
      setState(() {
        _nozzlesList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage Nozzles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error loading nozzles: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ),
                )
              : _nozzlesList.isEmpty
                  ? _buildEmptyState()
                  : _buildNozzlesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNozzleScreen()),
          );
          if (result == true) {
            _fetchNozzles(); // Refresh list after adding
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Nozzle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_gas_station_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No nozzles found.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your first nozzle to a fuel tank.',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNozzlesList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
      itemCount: _nozzlesList.length,
      itemBuilder: (context, index) {
        final nozzle = _nozzlesList[index];
        final id = nozzle['id'] as String;
        final name = nozzle['name'] as String? ?? 'Unknown Nozzle';
        final tankInfo = nozzle['tanks'] as Map<String, dynamic>?;
        final tankType = tankInfo?['type'] as String? ?? 'No Tank';
        
        // Define color based on fuel type
        Color tankColor = Colors.grey;
        if (tankType.toLowerCase() == 'petrol') tankColor = Colors.orange;
        if (tankType.toLowerCase() == 'diesel') tankColor = Colors.green;
        if (tankType.toLowerCase() == 'cng') tankColor = Colors.blue;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: tankColor.withValues(alpha: 0.15),
              radius: 24,
              child: Icon(Icons.local_gas_station, color: tankColor),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tankColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tankType, 
                        style: TextStyle(color: tankColor, fontWeight: FontWeight.bold, fontSize: 12)
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed),
              onPressed: () => _deleteNozzle(id, name),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteNozzle(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Nozzle'),
        content: Text('Are you sure you want to completely remove $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('nozzles').delete().eq('id', id);
        _fetchNozzles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nozzle disconnected successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting nozzle: \${e.toString()}')),
          );
        }
      }
    }
  }
}
