import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'add_customer_screen.dart';
import 'customer_ledger_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Khata'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final names = [
            'Rajesh Kumar',
            'Simran Cargo',
            'Transport Express',
            'Amit Singh',
            'Green Logistics',
          ];
          final balances = [12500.0, 45000.0, 8900.0, 0.0, 32000.0];

          return _CustomerCard(
            name: names[index],
            balance: balances[index],
            phone: '+91 98765 43210',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerLedgerScreen(name: names[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text(
          'Add Customer',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final String name;
  final String phone;
  final double balance;
  final VoidCallback onTap;

  const _CustomerCard({
    required this.name,
    required this.phone,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹ ${balance.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: balance > 0 ? AppTheme.dangerRed : Colors.grey,
                  ),
                ),
                Text(
                  'Balance',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
