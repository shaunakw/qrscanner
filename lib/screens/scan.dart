import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'history.dart';

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
            icon: const Icon(Icons.history),
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
              color: Colors.black.withAlpha(128),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(MdiIcons.cameraFlipOutline, color: Colors.white),
                    onPressed: () {
                      _controller?.flipCamera();
                    },
                  ),
                  IconButton(
                    icon: Icon(_flash ? MdiIcons.flash : MdiIcons.flashOutline, color: Colors.white),
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
