import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../models/line_item.dart';
import '../utils/calculations.dart';
import '../widgets/line_item_tile.dart';
import '../widgets/client_info_card.dart';
import '../widgets/totals_card_box.dart';
import 'preview_screen.dart';
import '../utils/storage.dart';

enum QuoteStatus { draft, sent, accepted }

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({Key? key}) : super(key: key);

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final List<LineItem> _items = [];
  final _listKey = GlobalKey<AnimatedListState>();

  final _clientName = TextEditingController();
  final _clientAddress = TextEditingController();
  final _reference = TextEditingController();
  final _clientFormKey = GlobalKey<FormState>();
  String _currencySymbol = '₹';
  QuoteStatus _status = QuoteStatus.draft;

  @override
  void initState() {
    super.initState();
    _insertItem(LineItem(name: 'Consulting', quantity: 1, rate: 1200));
    _loadSaved();
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientAddress.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _insertItem(LineItem item, [int? at]) {
    final idx = at ?? _items.length;
    _items.insert(idx, item);
    _listKey.currentState
        ?.insertItem(idx, duration: const Duration(milliseconds: 300));
  }

  void _removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return;
    final removed = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: LineItemTile(
            item: removed,
            onChanged: (_) {},
            onRemove: () {},
            compact: true,
          ),
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  void _updateItem(LineItem updated) {
    final i = _items.indexWhere((e) => e.id == updated.id);
    if (i >= 0) setState(() => _items[i] = updated);
  }

  Future<void> _saveQuoteLocally() async {
    final data = {
      'clientName': _clientName.text,
      'clientAddress': _clientAddress.text,
      'reference': _reference.text,
      'currencySymbol': _currencySymbol,
      'status': _status.toString(),
      'items': _items.map((e) => e.toJson()).toList(),
    };
    await Storage.saveQuote(data);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Saved locally'), behavior: SnackBarBehavior.floating));
  }

  Future<void> _loadSaved() async {
    final loaded = await Storage.loadQuote();
    if (loaded == null) return;
    setState(() {
      _clientName.text = loaded['clientName'] ?? '';
      _clientAddress.text = loaded['clientAddress'] ?? '';
      _reference.text = loaded['reference'] ?? '';
      _currencySymbol = loaded['currencySymbol'] ?? '₹';
      final raw = loaded['items'] as List<dynamic>? ?? [];
      _items.clear();
      for (var j in raw) {
        _items.add(LineItem.fromJson(Map<String, dynamic>.from(j)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = Calculations.subtotal(_items);
    final tax = Calculations.totalTax(_items);
    final total = Calculations.grandTotal(_items);

    // Breakpoints
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1200;
    final isDesktop = width >= 1200;
    final maxWidth = isDesktop ? 1200.0 : (isTablet ? 1000.0 : double.infinity);
    final numFmt = NumberFormat.currency(symbol: _currencySymbol);

    // Adaptive padding
    final outerPadding =
        EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: 12);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
            ),
            child: const FaIcon(
              FontAwesomeIcons.fileLines,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Product Quote Builder',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: _saveQuoteLocally,
            icon: const FaIcon(FontAwesomeIcons.floppyDisk,
                color: Colors.indigo, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: outerPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: isMobile
                ? _buildMobileLayout(numFmt, subtotal, tax, total)
                : _buildWideLayout(numFmt, subtotal, tax, total, isTablet),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      NumberFormat numFmt, double subtotal, double tax, double total) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Form(
        key: _clientFormKey,
        child: ClientInfoCard(
            nameController: _clientName,
            addressController: _clientAddress,
            referenceController: _reference),
      ),
      const SizedBox(height: 12),
      _sectionHeader(icon: FontAwesomeIcons.list, title: 'Line Items'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index, animation) {
            final item = _items[index];
            return SizeTransition(
              sizeFactor: animation,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: LineItemTile(
                    item: item,
                    onChanged: _updateItem,
                    onRemove: () => _removeItemAt(index)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final ok = _clientFormKey.currentState?.validate() ?? false;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Client info required'),
                    behavior: SnackBarBehavior.floating));
                return;
              }
              _insertItem(LineItem(name: 'New item', quantity: 1, rate: 0));
            },
            icon:
                const FaIcon(FontAwesomeIcons.circlePlus, color: Colors.white),
            label: const Text('Add item'),
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
            onPressed: () {
              final ok = _clientFormKey.currentState?.validate() ?? false;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Client info required'),
                    behavior: SnackBarBehavior.floating));
                return;
              }
              final clone = _items.isNotEmpty
                  ? LineItem.fromJson(_items.last.toJson())
                  : LineItem(name: 'Item', quantity: 1, rate: 0);
              _insertItem(clone);
            },
            child: const FaIcon(FontAwesomeIcons.copy)),
      ]),
      const SizedBox(height: 16),
      TotalsCardBox(
          subtotal: subtotal,
          tax: tax,
          total: total,
          currencySymbol: _currencySymbol),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: () {
          final ok = _clientFormKey.currentState?.validate() ?? false;
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Client info required'),
                behavior: SnackBarBehavior.floating));
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PreviewScreen(
                  clientName: _clientName.text,
                  clientAddress: _clientAddress.text,
                  reference: _reference.text,
                  items: _items,
                  currencySymbol: _currencySymbol,
                  status: _status.toString().split('.').last)));
        },
        icon: const FaIcon(FontAwesomeIcons.eye),
        label: const Text('Preview'),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      ),
    ]);
  }

  Widget _buildWideLayout(NumberFormat numFmt, double subtotal, double tax,
      double total, bool isTablet) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Left: form
      Expanded(
        flex: 7,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Form(
            key: _clientFormKey,
            child: ClientInfoCard(
                nameController: _clientName,
                addressController: _clientAddress,
                referenceController: _reference),
          ),
          const SizedBox(height: 14),
          _sectionHeader(icon: FontAwesomeIcons.list, title: 'Line Items'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03), blurRadius: 12)
                ]),
            child: Column(children: [
              AnimatedList(
                key: _listKey,
                initialItemCount: _items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, index, animation) {
                  final item = _items[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: LineItemTile(
                          item: item,
                          onChanged: _updateItem,
                          onRemove: () => _removeItemAt(index)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        final ok =
                            _clientFormKey.currentState?.validate() ?? false;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Client info required'),
                                  behavior: SnackBarBehavior.floating));
                          return;
                        }
                        _insertItem(
                            LineItem(name: 'New item', quantity: 1, rate: 0));
                      },
                      icon: const FaIcon(FontAwesomeIcons.circlePlus),
                      label: const Text('Add item')),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                      onPressed: () {
                        final ok =
                            _clientFormKey.currentState?.validate() ?? false;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Client info required'),
                                  behavior: SnackBarBehavior.floating));
                          return;
                        }
                        final clone = _items.isNotEmpty
                            ? LineItem.fromJson(_items.last.toJson())
                            : LineItem(name: 'Item', quantity: 1, rate: 0);
                        _insertItem(clone);
                      },
                      icon: const FaIcon(FontAwesomeIcons.copy),
                      label: const Text('Duplicate')),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _currencySymbol,
                    items: const [
                      DropdownMenuItem(value: '₹', child: Text('INR (₹)')),
                      DropdownMenuItem(value: '\$', child: Text('USD (\$)')),
                      DropdownMenuItem(value: '€', child: Text('EUR (€)')),
                    ],
                    onChanged: (v) =>
                        setState(() => _currencySymbol = v ?? '₹'),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
                onPressed: () {
                  final ok = _clientFormKey.currentState?.validate() ?? false;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Client info required'),
                        behavior: SnackBarBehavior.floating));
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PreviewScreen(
                          clientName: _clientName.text,
                          clientAddress: _clientAddress.text,
                          reference: _reference.text,
                          items: _items,
                          currencySymbol: _currencySymbol,
                          status: _status.toString().split('.').last)));
                },
                icon: const Icon(Icons.remove_red_eye_outlined),
                label: const Text('Preview'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
          )
        ]),
      ),

      const SizedBox(width: 20),

      // Right: totals & actions
      Expanded(
        flex: 4,
        child: Column(children: [
          TotalsCardBox(
              subtotal: subtotal,
              tax: tax,
              total: total,
              currencySymbol: _currencySymbol),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03), blurRadius: 12)
                ]),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(children: [
                    FaIcon(FontAwesomeIcons.gear, color: Colors.indigo),
                    SizedBox(width: 10),
                    Text('Actions',
                        style: TextStyle(fontWeight: FontWeight.w600))
                  ]),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _status = QuoteStatus.sent);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marked Sent')));
                      },
                      icon: const FaIcon(FontAwesomeIcons.paperPlane),
                      label: const Text('Mark Sent')),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _status = QuoteStatus.accepted);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marked Accepted')));
                      },
                      icon: const FaIcon(FontAwesomeIcons.circleCheck),
                      label: const Text('Mark Accepted')),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                      onPressed: _saveQuoteLocally,
                      icon: const FaIcon(FontAwesomeIcons.floppyDisk),
                      label: const Text('Save locally')),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _items.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cleared items')));
                      },
                      icon: const FaIcon(FontAwesomeIcons.trash,
                          color: Colors.redAccent),
                      label: const Text('Clear items')),
                ]),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PreviewScreen(
                      clientName: _clientName.text,
                      clientAddress: _clientAddress.text,
                      reference: _reference.text,
                      items: _items,
                      currencySymbol: _currencySymbol,
                      status: _status.toString().split('.').last)));
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03), blurRadius: 12)
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8)),
                          child: const FaIcon(FontAwesomeIcons.eye,
                              color: Colors.indigo)),
                      const SizedBox(width: 12),
                      const Text('Quick Preview',
                          style: TextStyle(fontWeight: FontWeight.w600))
                    ]),
                    const SizedBox(height: 12),
                    Text('Subtotal: ${numFmt.format(subtotal)}'),
                    Text('Tax: ${numFmt.format(tax)}'),
                    const SizedBox(height: 8),
                    Text('Total: ${numFmt.format(total)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
            ),
          )
        ]),
      ),
    ]);
  }

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8)),
          child: FaIcon(icon, color: Colors.indigo, size: 18)),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    ]);
  }
}
