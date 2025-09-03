// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonWebView extends StatefulWidget {
  const CommonWebView({
    super.key,
    required this.model,
  });

  final Map<String, dynamic> model;

  @override
  State<CommonWebView> createState() => _CommonWebViewState();
}

class _CommonWebViewState extends State<CommonWebView> {
  WebViewController controller = WebViewController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // if (progress >= 100) {
              //   _isLoading = false;
              //   setState(() {});
              // }
            },
            onPageStarted: (String url) async {
              _isLoading = true;
              setState(() {});
            },
            onPageFinished: (String url) async {
              await controller.runJavaScript('''
    (function() {
      // Try common header selectors
      const headerSelectors = [
        'header', 
        '.header', 
        '#header',
        'nav', 
        '.navbar',
        '#navbar',
        '.site-header',
        '.main-header',
        '.page-header'
      ];
      
      headerSelectors.forEach(selector => {
        const elements = document.querySelectorAll(selector);
        elements.forEach(el => {
          if(el) el.style.display = 'none';
        });
      });
    })();
  ''');
              _isLoading = false;
              setState(() {});
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint("WebResourceError is ${error.description}");
            },
            onNavigationRequest: (NavigationRequest request) async {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.model['url'] ?? ""));
      setState(() {});
    });
  }

  @override
  void dispose() async {
    controller.clearCache();
    controller.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await controller.clearCache();
          await controller.clearLocalStorage();
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: widget.model['title'],
            onBack: () async {
              Navigator.pop(context);
            },
          ),
          body: SafeArea(
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ));
  }
}
