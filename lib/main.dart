import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController(
    text:
        "https://virtualchat.virtualspirit.me/widget?website_token=v8pLycCQY7CJKqM8gSLDEocP#/",
  );

  // Singleton WebViewController (Keeps session & cache)
  static late final WebViewController _webViewController;

  // Initialize WebView with Cache, LocalStorage, and Cookies
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
          ) // Custom user-agent
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) async {
                await _saveCookies(); // Save cookies on page load
              },
            ),
          );

    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   (WebViewPlatform.instance as WebKitWebViewPlatform)
    //       .createWebViewControllerCreationParams()
    //       .allowsInlineMediaPlayback = true;
    // } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
    //   (WebViewPlatform.instance as AndroidWebViewPlatform)
    //       .createWebViewControllerCreationParams()
    //       .enableDomStorage = true; // Enable localStorage
    // }
  }

  void _openWebView() {
    _restoreCookies(); // Restore cookies before opening
    _webViewController.loadRequest(Uri.parse(_urlController.text));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => WebViewModal(
            controller: _webViewController,
            url: _urlController.text,
          ),
    );
  }

  // Restore cookies before opening WebView
  Future<void> _restoreCookies() async {
    WebViewCookieManager().setCookie(
      WebViewCookie(
        name: "session",
        value: "saved-session-token",
        domain: "virtualchat.virtualspirit.me",
      ),
    );
  }

  // Save cookies when WebView is closed
  Future<void> _saveCookies() async {
    debugPrint("Saving Cookies...");
    // Unfortunately, `getCookies()` is not available in webview_flutter,
    // but the session remains as long as the WebViewController is persistent.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Home Screen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'Enter URL',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWebView,
        child: const Icon(Icons.open_in_browser),
      ),
    );
  }
}

class WebViewModal extends StatelessWidget {
  final WebViewController controller;
  final String url;

  const WebViewModal({super.key, required this.controller, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
