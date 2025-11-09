import 'package:uuid/uuid.dart';

class LineItem {
  String id;
  String name;
  double quantity;
  double rate;
  double discount;
  double taxPercent;
  bool taxInclusive;

  LineItem({
    String? id,
    this.name = '',
    this.quantity = 1.0,
    this.rate = 0.0,
    this.discount = 0.0,
    this.taxPercent = 0.0,
    this.taxInclusive = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'rate': rate,
        'discount': discount,
        'taxPercent': taxPercent,
        'taxInclusive': taxInclusive,
      };

  static LineItem fromJson(Map<String, dynamic> json) => LineItem(
        id: json['id'] as String?,
        name: json['name'] ?? '',
        quantity: (json['quantity'] ?? 1).toDouble(),
        rate: (json['rate'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        taxPercent: (json['taxPercent'] ?? 0).toDouble(),
        taxInclusive: json['taxInclusive'] ?? false,
      );
}
