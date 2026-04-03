import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Equipment & Maintenance Module
/// Tracks dispenser maintenance logs and complaint handling
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _issues = [
    {
      'id': '1',
      'equipment': 'Dispenser #1',
      'issue': 'Meter calibration issue',
      'status': 'open',
      'reportedAt': DateTime.now().subtract(const Duration(days: 2)),
      'priority': 'high',
    },
    {
      'id': '2',
      'equipment': 'Pump #3',
      'issue': 'Slow flow rate',
      'status': 'in_progress',
      'reportedAt': DateTime.now().subtract(const Duration(days: 1)),
      'priority': 'medium',
    },
    {
      'id': '3',
      'equipment': 'Tank #2',
      'issue': 'Leak detection sensor',
      'status': 'resolved',
      'reportedAt': DateTime.now().subtract(const Duration(days: 5)),
      'priority': 'high',
    },
  ];

  final List<Map<String, dynamic>> _maintenanceSchedule = [
    {
      'equipment': 'Dispenser #1',
      'task': 'Annual calibration',
      'dueDate': DateTime.now().add(const Duration(days: 7)),
      'frequency': 'Yearly',
    },
    {
      'equipment': 'Pump #2',
      'task': 'Filter replacement',
      'dueDate': DateTime.now().add(const Duration(days: 14)),
      'frequency': 'Monthly',
    },
    {
      'equipment': 'Tank #1',
      'task': 'Inspection',
      'dueDate': DateTime.now().add(const Duration(days: 30)),
      'frequency': 'Quarterly',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.dangerRed;
      case 'medium':
        return AppTheme.fuelGold;
      case 'low':
        return AppTheme.successGreen;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppTheme.dangerRed;
      case 'in_progress':
        return AppTheme.fuelGold;
      case 'resolved':
        return AppTheme.successGreen;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment & Maintenance'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Issues', icon: Icon(Icons.report_problem)),
            Tab(text: 'Schedule', icon: Icon(Icons.schedule)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddIssueDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Report Issue'),
        backgroundColor: AppTheme.accentColor,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildIssuesTab(), _buildScheduleTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildIssuesTab() {
    final openIssues = _issues.where((i) => i['status'] != 'resolved').toList();

    if (openIssues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.successGreen,
            ),
            const SizedBox(height: 16),
            const Text('No open issues', style: TextStyle(fontSize: 18)),
            const Text('All equipment is running smoothly'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: openIssues.length,
      itemBuilder: (context, index) {
        final issue = openIssues[index];
        return _IssueCard(
          issue: issue,
          priorityColor: _getPriorityColor(issue['priority']),
          statusColor: _getStatusColor(issue['status']),
          statusText: _getStatusText(issue['status']),
          onResolve: () => _resolveIssue(issue['id']),
          onUpdate: () => _showUpdateDialog(context, issue),
        );
      },
    );
  }

  Widget _buildScheduleTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _maintenanceSchedule.length,
      itemBuilder: (context, index) {
        final schedule = _maintenanceSchedule[index];
        return _ScheduleCard(schedule: schedule);
      },
    );
  }

  Widget _buildHistoryTab() {
    final resolvedIssues = _issues
        .where((i) => i['status'] == 'resolved')
        .toList();

    if (resolvedIssues.isEmpty) {
      return const Center(child: Text('No maintenance history'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resolvedIssues.length,
      itemBuilder: (context, index) {
        final issue = resolvedIssues[index];
        return _HistoryCard(issue: issue);
      },
    );
  }

  void _resolveIssue(String id) {
    setState(() {
      final index = _issues.indexWhere((i) => i['id'] == id);
      if (index != -1) {
        _issues[index]['status'] = 'resolved';
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Issue marked as resolved')));
  }

  void _showAddIssueDialog(BuildContext context) {
    final equipmentController = TextEditingController();
    final issueController = TextEditingController();
    String selectedPriority = 'medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: equipmentController,
              decoration: const InputDecoration(
                labelText: 'Equipment',
                hintText: 'e.g., Dispenser #1',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: issueController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Issue Description',
                hintText: 'Describe the problem...',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedPriority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) => selectedPriority = value ?? 'medium',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (equipmentController.text.isNotEmpty &&
                  issueController.text.isNotEmpty) {
                setState(() {
                  _issues.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'equipment': equipmentController.text,
                    'issue': issueController.text,
                    'status': 'open',
                    'reportedAt': DateTime.now(),
                    'priority': selectedPriority,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Map<String, dynamic> issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update: ${issue['equipment']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(issue['issue']),
            const SizedBox(height: 16),
            const Text('Change status:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Open'),
                  selected: issue['status'] == 'open',
                  onSelected: (_) {
                    setState(() => issue['status'] = 'open');
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('In Progress'),
                  selected: issue['status'] == 'in_progress',
                  onSelected: (_) {
                    setState(() => issue['status'] = 'in_progress');
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('Resolved'),
                  selected: issue['status'] == 'resolved',
                  onSelected: (_) {
                    setState(() => issue['status'] = 'resolved');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final Map<String, dynamic> issue;
  final Color priorityColor;
  final Color statusColor;
  final String statusText;
  final VoidCallback onResolve;
  final VoidCallback onUpdate;

  const _IssueCard({
    required this.issue,
    required this.priorityColor,
    required this.statusColor,
    required this.statusText,
    required this.onResolve,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  issue['equipment'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    issue['priority'].toString().toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(issue['issue']),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Reported ${_formatDate(issue['reportedAt'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUpdate,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.build, color: AppTheme.accentColor),
        title: Text(schedule['task']),
        subtitle: Text('${schedule['equipment']} - ${schedule['frequency']}'),
        trailing: Text(
          'Due: ${_formatDate(schedule['dueDate'])}',
          style: TextStyle(
            color: schedule['dueDate'].isBefore(DateTime.now())
                ? AppTheme.dangerRed
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> issue;

  const _HistoryCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: AppTheme.successGreen),
        title: Text(issue['issue']),
        subtitle: Text(issue['equipment']),
        trailing: Text(
          _formatDate(issue['reportedAt']),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
