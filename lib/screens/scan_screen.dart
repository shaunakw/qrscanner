import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrscanner/screens/data_screen.dart';
import 'package:qrscanner/screens/history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey _qrKey = GlobalKey();
  late final Future<SharedPreferences> _prefs;

  QRViewController? _controller;
  bool _flash = false;

  void _initController(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    barcodeEquals(Barcode b1, Barcode b2) => b1.code == b2.code;
    _controller?.scannedDataStream.distinct(barcodeEquals).listen((data) async {
      _updatePref('scans', data.code);
      _updatePref('dates', DateTime.now().toString());

      _controller!.pauseCamera();
      await Navigator.push(context, MaterialPageRoute(
        builder: (_) => DataScreen(data: data.code),
      ));
      _controller!.resumeCamera();
    });
  }

  void _initPrefs(SharedPreferences prefs) {
    if (!prefs.containsKey('scans') || !prefs.containsKey('dates')) {
      prefs.setStringList('scans', []);
      prefs.setStringList('dates', []);
    }
  }

  void _updatePref(String key, String value) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(key)!;

    list.insert(0, value);
    if (list.length > historySize) {
      list.removeLast();
    }
    prefs.setStringList(key, list);
  }

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance().then((prefs) {
      _initPrefs(prefs);
      return prefs;
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
              final prefs = await _prefs;

              _controller?.pauseCamera();
              await Navigator.push(context, MaterialPageRoute(
                builder: (_) => HistoryScreen(prefs: prefs),
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
