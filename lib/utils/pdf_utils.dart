// Conditional export: picks the web or non-web implementation depending on
// whether dart:html is available.
export 'pdf_utils_io.dart' if (dart.library.html) 'pdf_utils_web.dart';
