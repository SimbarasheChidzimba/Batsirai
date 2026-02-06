import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app Stripe checkout session.
/// Loads the session URL in a WebView (no browser redirect).
/// Pops with [true] on success redirect, [false] on back/close.
class StripeCheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const StripeCheckoutWebViewScreen({
    super.key,
    required this.checkoutUrl,
  });

  @override
  State<StripeCheckoutWebViewScreen> createState() =>
      _StripeCheckoutWebViewScreenState();
}

class _StripeCheckoutWebViewScreenState extends State<StripeCheckoutWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {},
          onProgress: (progress) {
            if (mounted) {
              setState(() => _isLoading = progress < 100);
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _checkForSuccessOrCancel(url);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkForSuccessOrCancel(String url) {
    final lower = url.toLowerCase();
    // Common Stripe / backend success patterns
    if (lower.contains('success') ||
        lower.contains('payment/success') ||
        lower.contains('checkout/success') ||
        lower.contains('complete')) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }
    if (lower.contains('cancel') || lower.contains('cancelled')) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
