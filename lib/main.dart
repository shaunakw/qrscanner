import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qrscanner/models/scan.dart';
import 'package:qrscanner/screens/scan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ScanAdapter());
  await Hive.openBox<Scan>('history');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme().copyWith(
          headline6: GoogleFonts.nunitoSans(fontWeight: FontWeight.w700),
        ),
      ),
      home: const ScanScreen(),
    );
  }
}
