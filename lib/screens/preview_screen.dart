import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../utils/pdf_utils.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/line_item.dart';
import '../utils/calculations.dart';

class PreviewScreen extends StatelessWidget {
  final String clientName;
  final String clientAddress;
  final String reference;
  final List<LineItem> items;
  final String currencySymbol;
  final String status;

  const PreviewScreen(
      {Key? key,
      required this.clientName,
      required this.clientAddress,
      required this.reference,
      required this.items,
      this.currencySymbol = '₹',
      this.status = 'Draft'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: currencySymbol);
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 900 ? 900.0 : width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Preview'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
        ),
        actions: [
          IconButton(
            tooltip: 'Print',
            onPressed: () async {
              await _printReceipt(fmt);
            },
            icon: const FaIcon(FontAwesomeIcons.print),
          ),
          IconButton(
            tooltip: 'Save PDF',
            onPressed: () async {
              await _savePdf(fmt);
            },
            icon: const FaIcon(FontAwesomeIcons.download),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('QUOTE',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text('Ref: $reference',
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                  Text('Status: $status',
                                      style: TextStyle(
                                          color: Colors.grey.shade600))
                                ]),
                            const Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Black Horse Pvt Ltd',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Hillside Estate, Malabar Hill'),
                                  Text('Black878@gmail.com')
                                ]),
                          ]),
                      const SizedBox(height: 18),
                      Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.indigo.shade50),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bill To',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Text(clientName),
                                Text(clientAddress)
                              ])),
                      const SizedBox(height: 18),
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade200),
                        columnWidths: const {
                          0: FlexColumnWidth(4),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2)
                        },
                        children: [
                          const TableRow(
                              decoration:
                                  BoxDecoration(color: Color(0xFFF1F5F9)),
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Description',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700))),
                                Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Qty')),
                                Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Rate')),
                                Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Amount'))
                              ]),
                          ...items.map((i) {
                            final amount = Calculations.itemTotal(i);
                            return TableRow(children: [
                              Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(i.name)),
                              Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(i.quantity.toString())),
                              Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(fmt.format(i.rate))),
                              Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(fmt.format(amount))),
                            ]);
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    'Subtotal: ${fmt.format(Calculations.subtotal(items))}'),
                                Text(
                                    'Tax: ${fmt.format(Calculations.totalTax(items))}'),
                                const SizedBox(height: 6),
                                Text(
                                    'Grand Total: ${fmt.format(Calculations.grandTotal(items))}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                              ])),
                      const SizedBox(height: 18),
                      const Text('Notes:',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text(
                          'Thank you for your business. Payment due in 30 days.'),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt(NumberFormat fmt) async {
    final bytes = await _buildPdf(fmt);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  Future<Uint8List> _buildPdf(NumberFormat fmt) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return <pw.Widget>[
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('QUOTE',
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('Ref: $reference'),
                        pw.Text('Status: $status'),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Black Horse Pvt Ltd',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Hillside Estate, Malabar Hill'),
                        pw.Text('Black878@gmail.com')
                      ])
                ]),
            pw.SizedBox(height: 12),
            pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(color: PdfColors.blue50),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 6),
                      pw.Text(clientName),
                      pw.Text(clientAddress)
                    ])),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
                context: ctx,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: ['Description', 'Qty', 'Rate', 'Amount'],
                data: items.map((i) {
                  final amount = Calculations.itemTotal(i);
                  return [
                    i.name,
                    i.quantity.toString(),
                    fmt.format(i.rate),
                    fmt.format(amount)
                  ];
                }).toList()),
            pw.SizedBox(height: 12),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('Subtotal: ${fmt.format(Calculations.subtotal(items))}'),
              pw.Text('Tax: ${fmt.format(Calculations.totalTax(items))}'),
              pw.SizedBox(height: 6),
              pw.Text(
                  'Grand Total: ${fmt.format(Calculations.grandTotal(items))}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
            ]),
            pw.SizedBox(height: 12),
            pw.Text('Notes:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Text('Thank you for your business. Payment due in 30 days.')
          ];
        }));

    return doc.save();
  }

  Future<void> _savePdf(NumberFormat fmt) async {
    final bytes = await _buildPdf(fmt);
    final filename =
        reference.isNotEmpty ? 'quote-$reference.pdf' : 'quote.pdf';
    await savePdf(bytes, filename);
  }
}
