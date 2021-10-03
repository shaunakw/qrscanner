import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrscanner/models/scan.dart';
import 'package:qrscanner/screens/data_screen.dart';
import 'package:qrscanner/screens/history_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey _qrKey = GlobalKey();

  QRViewController? _controller;
  bool _flash = false;

  void _initController(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    barcodeEquals(Barcode b1, Barcode b2) => b1.code == b2.code;
    _controller?.scannedDataStream.distinct(barcodeEquals).listen((data) async {
      final scan = Scan(data.code);
      Hive.box<Scan>('history').add(scan);

      _controller!.pauseCamera();
      await Navigator.push(context, MaterialPageRoute(
        builder: (_) => DataScreen(scan: scan, isNew: true),
      ));
      _controller!.resumeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.history, size: 20.0),
            onPressed: () async {
              _controller?.pauseCamera();
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              ));
              _controller?.resumeCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _initController,
          ),
          if (_controller != null)
            ColoredBox(
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.syncAlt, color: Colors.white, size: 20.0),
                    onPressed: () {
                      _controller?.flipCamera();
                    },
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.bolt,
                        color: Colors.white.withOpacity(_flash ? 1.0 : 0.5), size: 20.0),
                    onPressed: () {
                      _controller?.toggleFlash();
                      setState(() {
                        _flash = !_flash;
                      });
                    },
                  ),
                ],
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
