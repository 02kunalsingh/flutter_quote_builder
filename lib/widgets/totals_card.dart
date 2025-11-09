import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalsCardBox extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final String currencySymbol;

  const TotalsCardBox({Key? key, required this.subtotal, required this.tax, required this.total, this.currencySymbol = '₹'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: currencySymbol);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF8FAFF)]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16)]),
      child: Column(children: [
        Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.paid_outlined, color: Colors.indigo)), const SizedBox(width: 12), const Text('Totals', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))]),
        const SizedBox(height: 16),
        _row('Subtotal', fmt.format(subtotal)),
        const SizedBox(height: 8),
        _row('Tax', fmt.format(tax)),
        const Divider(height: 18, thickness: 1),
        _row('Grand Total', fmt.format(total), isStrong: true),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('Export (coming soon)'), style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
      ]),
    );
  }

  Widget _row(String label, String value, {bool isStrong = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey.shade700)), Text(value, style: TextStyle(fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600, fontSize: isStrong ? 16 : 14))]);
  }
}
