import '../models/line_item.dart';

class Calculations {
  static double itemPreTaxAmount(LineItem item) {
    final effectiveRate = (item.rate - item.discount);
    final preTax = effectiveRate * item.quantity;
    return preTax;
  }

  static double itemTaxAmount(LineItem item) {
    final preTax = itemPreTaxAmount(item);
    if (item.taxInclusive) {
      final divisor = 1 + (item.taxPercent / 100.0);
      final net = preTax / divisor;
      return preTax - net;
    } else {
      return preTax * (item.taxPercent / 100.0);
    }
  }

  static double itemTotal(LineItem item) {
    final preTax = itemPreTaxAmount(item);
    final tax = itemTaxAmount(item);
    return preTax + tax;
  }

  static double subtotal(List<LineItem> items) =>
      items.fold(0.0, (s, i) => s + itemPreTaxAmount(i));

  static double totalTax(List<LineItem> items) =>
      items.fold(0.0, (s, i) => s + itemTaxAmount(i));

  static double grandTotal(List<LineItem> items) =>
      items.fold(0.0, (s, i) => s + itemTotal(i));
}
