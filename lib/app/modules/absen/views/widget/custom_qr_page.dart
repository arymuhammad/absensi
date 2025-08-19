import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'custom_scan_line_animation.dart';

class CustomQrScannerPage extends StatefulWidget {
  final Function(String) onDetect;
  const CustomQrScannerPage({super.key, required this.onDetect});
  @override
  State<StatefulWidget> createState() => _CustomQrScannerPageState();
}

class _CustomQrScannerPageState extends State<CustomQrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) {
      if (scanData.code!.split(' ').length <= 2) {
        controller?.pauseCamera();
        Navigator.of(context).pop();
        showToast('QR tidak dikenali');
      } else {
        widget.onDetect(scanData.code ?? '');
        // print('ini hasil scan ${scanData.code}');
        controller?.pauseCamera();
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: const Color.fromARGB(189, 0, 0, 0),
              borderColor: Colors.greenAccent,
              borderRadius: 16,
              borderLength: 32,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          // Ilustrasi di tengah
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 56),
                ScanLineAnimation(
                  width: 280, // sesuaikan lebar area scan
                  height: 300, // sesuaikan tinggi area scan
                ),
                SizedBox(height: 32),
                Text(
                  "Arahkan QR ke area kotak",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Tombol close di pojok atas
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
