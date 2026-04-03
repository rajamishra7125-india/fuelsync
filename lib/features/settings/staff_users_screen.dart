import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_staff_screen.dart';

class StaffUsersScreen extends StatefulWidget {
  const StaffUsersScreen({super.key});

  @override
  State<StaffUsersScreen> createState() => _StaffUsersScreenState();
}

class _StaffUsersScreenState extends State<StaffUsersScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _staffList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      // In a real app we would restrict to the current pump_id.
      final response = await _supabase
          .from('user_profiles')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _staffList = List<Map<String, dynamic>>.from(response);
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
        title: const Text('Staff Users'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error loading staff: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ),
                )
              : _staffList.isEmpty
                  ? _buildEmptyState()
                  : _buildStaffList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffScreen()),
          );
          if (result == true) {
            _fetchStaff(); // Refresh list after adding
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No staff users found.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the button below to add your first operator or manager.',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
      itemCount: _staffList.length,
      itemBuilder: (context, index) {
        final staff = _staffList[index];
        final name = staff['name'] as String? ?? 'Unknown';
        final role = staff['role'] as String? ?? 'Operator';
        final pin = staff['pin'] as String? ?? 'No PIN';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              radius: 24,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Role: $role', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text('Login PIN: $pin', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed),
              onPressed: () => _deleteStaff(staff['id'] as String, name),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteStaff(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to remove $name?'),
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
        await _supabase.from('user_profiles').delete().eq('id', id);
        _fetchStaff();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff member removed.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting staff: \${e.toString()}')),
          );
        }
      }
    }
  }
}
