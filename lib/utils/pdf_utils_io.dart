import 'dart:typed_data';
import 'package:printing/printing.dart';

Future<void> savePdf(Uint8List bytes, String filename) async {
  // On non-web platforms, use the printing package's share helper which
  // opens the native share/save dialog.
  await Printing.sharePdf(bytes: bytes, filename: filename);
}
