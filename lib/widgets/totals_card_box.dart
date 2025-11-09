// lib/widgets/totals_card_box.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalsCardBox extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final String currencySymbol;

  const TotalsCardBox({
    Key? key,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.currencySymbol = '₹',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numFmt = NumberFormat.currency(symbol: currencySymbol);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Quote Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text(numFmt.format(subtotal)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax:'),
                Text(numFmt.format(tax)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(numFmt.format(total),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
