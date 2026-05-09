import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:base_flutter/core/base/theme/app_text_styles.dart';
import 'package:base_flutter/core/base/utils/logger.dart';
import 'package:base_flutter/core/base/widgets/scanner/scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A full-screen barcode/QR scanner page.
///
/// Usage:
/// ```dart
/// final result = await BarcodeScannerPage.show(context);
/// if (result != null) {
///   // Use scanned code
/// }
/// ```
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({
    super.key,
    this.title = 'Quét mã',
    this.hintText = 'Đưa mã vạch vào khung để quét',
    this.allowMultipleScan = false,
  });

  /// Title displayed in the AppBar.
  final String title;

  /// Hint text displayed below the scan window.
  final String hintText;

  /// If true, the scanner stays open after a scan. Defaults to false.
  final bool allowMultipleScan;

  /// Convenience method to open the scanner and get the result.
  static Future<String?> show(
    BuildContext context, {
    String title = 'Quét mã',
    String hintText = 'Đưa mã vạch vào khung để quét',
    bool allowMultipleScan = false,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BarcodeScannerPage(
          title: title,
          hintText: hintText,
          allowMultipleScan: allowMultipleScan,
        ),
      ),
    );
  }

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  bool _hasScanned = false;

  @override
  Future<void> dispose() async {
    await _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned && !widget.allowMultipleScan) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _hasScanned = true;

    // Haptic feedback on successful scan
    await HapticFeedback.mediumImpact();

    if (!mounted) return;

    if (!widget.allowMultipleScan) {
      AppLogger.i('Scanned code: $code');
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildCloseButton(),
        title: Text(
          widget.title,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [_buildFlashToggle(), _buildCameraSwitch()],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay with scanning window
          ScannerOverlay(hintText: widget.hintText),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildFlashToggle() {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, state, child) {
        final torchOn = state.torchState == TorchState.on;

        return IconButton(
          onPressed: _controller.toggleTorch,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: torchOn ? AppColors.primary : Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              torchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraSwitch() {
    return IconButton(
      onPressed: _controller.switchCamera,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.cameraswitch_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
