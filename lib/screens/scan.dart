import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? _controller;
  bool _flash = false;

  void _initController(QRViewController controller) {
    _controller = controller;
    _controller?.scannedDataStream.listen((data) {
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _initController,
          ),
          ColoredBox(
            color: Colors.black.withAlpha(128),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.flip_camera_android, color: Colors.white),
                  onPressed: () {
                    _controller?.flipCamera();
                  },
                ),
                IconButton(
                  icon: Icon(_flash ? Icons.flash_off : Icons.flash_on_outlined, color: Colors.white),
                  onPressed: () {
                    _controller?.toggleFlash();
                    setState(() {
                      _flash = !_flash;
                    });
                  },
                ),
              ],
            ),
          ),
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
