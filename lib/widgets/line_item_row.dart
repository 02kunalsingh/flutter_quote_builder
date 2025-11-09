// lib/widgets/line_item_row.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/line_item.dart';

typedef OnItemChanged = void Function(LineItem);

class LineItemRow extends StatefulWidget {
  final LineItem item;
  final VoidCallback onRemove;
  final OnItemChanged onChanged;

  const LineItemRow({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends State<LineItemRow> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _rateController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _qtyController =
        TextEditingController(text: widget.item.quantity.toString());
    _rateController = TextEditingController(text: widget.item.rate.toString());
    _discountController =
        TextEditingController(text: widget.item.discount.toString());
    _taxController =
        TextEditingController(text: widget.item.taxPercent.toString());
  }

  void _updateModel() {
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final updated = LineItem(
      id: widget.item.id,
      name: _nameController.text,
      quantity: qty,
      rate: rate,
      discount: discount,
      taxPercent: tax,
      taxInclusive: widget.item.taxInclusive,
    );
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Product / Service'),
                  onChanged: (_) => _updateModel(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  decoration: const InputDecoration(labelText: 'Qty'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\.]'))
                  ],
                  onChanged: (_) => _updateModel(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _rateController,
                  decoration: const InputDecoration(labelText: 'Rate'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\.]'))
                  ],
                  onChanged: (_) => _updateModel(),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    decoration: const InputDecoration(labelText: 'Discount'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\.]'))
                    ],
                    onChanged: (_) => _updateModel(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _taxController,
                    decoration: const InputDecoration(labelText: 'Tax %'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\.]'))
                    ],
                    onChanged: (_) => _updateModel(),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: widget.item.taxInclusive,
                          onChanged: (v) {
                            final updated = LineItem(
                              id: widget.item.id,
                              name: _nameController.text,
                              quantity:
                                  double.tryParse(_qtyController.text) ?? 1.0,
                              rate:
                                  double.tryParse(_rateController.text) ?? 0.0,
                              discount:
                                  double.tryParse(_discountController.text) ??
                                      0.0,
                              taxPercent:
                                  double.tryParse(_taxController.text) ?? 0.0,
                              taxInclusive: v ?? false,
                            );
                            widget.onChanged(updated);
                          },
                        ),
                        const Text('Tax incl')
                      ],
                    ),
                    IconButton(
                      onPressed: widget.onRemove,
                      icon: const FaIcon(Icons.delete, color: Colors.red),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
