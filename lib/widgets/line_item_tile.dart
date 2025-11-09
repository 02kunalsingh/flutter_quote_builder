import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../models/line_item.dart';
import '../utils/calculations.dart';

typedef OnItemChanged = void Function(LineItem);

class LineItemTile extends StatefulWidget {
  final LineItem item;
  final VoidCallback onRemove;
  final OnItemChanged onChanged;
  final bool compact;

  const LineItemTile(
      {Key? key,
      required this.item,
      required this.onRemove,
      required this.onChanged,
      this.compact = false})
      : super(key: key);

  @override
  State<LineItemTile> createState() => _LineItemTileState();
}

class _LineItemTileState extends State<LineItemTile> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _rateController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;

  final numFmt = NumberFormat("#,##0.00", "en_US");

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

  void _pushChange() {
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
    final amount = Calculations.itemTotal(widget.item);
    final width = MediaQuery.of(context).size.width;
    final compactLayout = width < 420;

    return Material(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: const FaIcon(FontAwesomeIcons.bagShopping,
                    color: Colors.indigo)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Product / Service name'),
                style: const TextStyle(fontWeight: FontWeight.w600),
                onChanged: (_) => _pushChange(),
              ),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(numFmt.format(amount),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Amount',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ]),
            const SizedBox(width: 8),
            IconButton(
                onPressed: widget.onRemove,
                icon: const FaIcon(FontAwesomeIcons.trash,
                    color: Colors.redAccent),
                tooltip: 'Remove item'),
          ]),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (ctx, box) {
            if (compactLayout) {
              return Wrap(spacing: 8, runSpacing: 8, children: [
                SizedBox(
                    width: box.maxWidth / 2 - 12,
                    child: _smallField(
                        controller: _qtyController,
                        label: 'Qty',
                        onChanged: _pushChange)),
                SizedBox(
                    width: box.maxWidth / 2 - 12,
                    child: _smallField(
                        controller: _rateController,
                        label: 'Rate',
                        onChanged: _pushChange)),
                SizedBox(
                    width: box.maxWidth / 2 - 12,
                    child: _smallField(
                        controller: _discountController,
                        label: 'Disc',
                        onChanged: _pushChange)),
                SizedBox(
                    width: box.maxWidth / 2 - 12,
                    child: _smallField(
                        controller: _taxController,
                        label: 'Tax %',
                        onChanged: _pushChange)),
              ]);
            } else {
              return Row(children: [
                Expanded(
                    child: _smallField(
                        controller: _qtyController,
                        label: 'Qty',
                        onChanged: _pushChange)),
                const SizedBox(width: 8),
                Expanded(
                    child: _smallField(
                        controller: _rateController,
                        label: 'Rate',
                        onChanged: _pushChange)),
                const SizedBox(width: 8),
                Expanded(
                    child: _smallField(
                        controller: _discountController,
                        label: 'Disc',
                        onChanged: _pushChange)),
                const SizedBox(width: 8),
                Expanded(
                    child: _smallField(
                        controller: _taxController,
                        label: 'Tax %',
                        onChanged: _pushChange)),
              ]);
            }
          }),
          const SizedBox(height: 8),
          Row(children: [
            Checkbox(
                value: widget.item.taxInclusive,
                onChanged: (v) {
                  final updated = LineItem(
                    id: widget.item.id,
                    name: _nameController.text,
                    quantity: double.tryParse(_qtyController.text) ??
                        widget.item.quantity,
                    rate: double.tryParse(_rateController.text) ??
                        widget.item.rate,
                    discount: double.tryParse(_discountController.text) ??
                        widget.item.discount,
                    taxPercent: double.tryParse(_taxController.text) ??
                        widget.item.taxPercent,
                    taxInclusive: v ?? false,
                  );
                  widget.onChanged(updated);
                }),
            const Text('Tax inclusive'),
            const Spacer(),
            Row(children: [
              const FaIcon(FontAwesomeIcons.circleInfo,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text('Preview: ${numFmt.format(amount)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey))
            ])
          ])
        ]),
      ),
    );
  }

  Widget _smallField(
      {required TextEditingController controller,
      required String label,
      required VoidCallback onChanged}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\.]'))],
      onChanged: (_) => onChanged(),
    );
  }
}
