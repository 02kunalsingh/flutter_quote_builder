import 'package:flutter/material.dart';
import 'screens/quote_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const ProductQuoteApp());

class ProductQuoteApp extends StatelessWidget {
  const ProductQuoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      primarySwatch: Colors.indigo,
      useMaterial3: false,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MaterialApp(
      title: 'Product Quote Builder',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const QuoteScreen(),
    );
  }
}
