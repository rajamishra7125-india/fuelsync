import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'credit_payment_screen.dart';

class CustomerLedgerScreen extends StatelessWidget {
  final String name;

  const CustomerLedgerScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          // Header summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance Due',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '₹ 45,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreditPaymentScreen(),
                      ),
                    );
                  },
                  child: const Text('Add Payment'),
                ),
              ],
            ),
          ),

          // Ledger Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Desc',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Sale',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.dangerRed,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Pay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Bal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 10,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('23/03', style: TextStyle(fontSize: 12)),
                      ),
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Fuel (P) 45L',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '4.5k',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.dangerRed,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text('-', style: TextStyle(fontSize: 12)),
                      ),
                      const Expanded(
                        child: Text(
                          '45k',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
