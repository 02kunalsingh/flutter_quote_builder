// Web implementation that triggers a browser download using an anchor element.
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:typed_data';
import 'dart:html' as html;

Future<void> savePdf(Uint8List bytes, String filename) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  try {
    final anchor = html.document.createElement('a') as html.AnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  } catch (e) {
    // Fallback: open in new tab. User can then save from browser PDF viewer.
    try {
      html.window.open(url, '_blank');
    } catch (e2) {
      html.window.console.error('Failed to download PDF: $e / $e2');
    }
  } finally {
    html.Url.revokeObjectUrl(url);
  }
}
