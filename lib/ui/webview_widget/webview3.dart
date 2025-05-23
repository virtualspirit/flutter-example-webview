import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_project/data/local/entity/chatwoot_user.dart';
import 'package:my_project/ui/webview_widget/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_flutter_android;
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

///Chatwoot webview widget
/// {@category FlutterClientSdk}
class Webview extends StatefulWidget {
  /// Url for Chatwoot widget in webview
  late final String widgetUrl;

  /// Chatwoot user & locale initialisation script
  late final String injectedJavaScript;

  /// See [ChatwootWidget.closeWidget]
  final void Function()? closeWidget;

  /// See [ChatwootWidget.onAttachFile]
  final Future<List<String>> Function()? onAttachFile;

  /// See [ChatwootWidget.onLoadStarted]
  final void Function()? onLoadStarted;

  /// See [ChatwootWidget.onLoadProgress]
  final void Function(int)? onLoadProgress;

  /// See [ChatwootWidget.onLoadCompleted]
  final void Function()? onLoadCompleted;

  Webview({
    Key? key,
    required String websiteToken,
    required String baseUrl,
    ChatwootUser? user,
    String locale = "en",
    customAttributes,
    this.closeWidget,
    this.onAttachFile,
    this.onLoadStarted,
    this.onLoadProgress,
    this.onLoadCompleted,
  }) : super(key: key) {
    widgetUrl =
        "${baseUrl}/widget?website_token=${websiteToken}&locale=${locale}";

    injectedJavaScript = generateScripts(
      user: user,
      locale: locale,
      customAttributes: customAttributes,
    );
  }

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  WebViewController? _controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String webviewUrl = widget.widgetUrl;
      setState(() {
        _controller =
            WebViewControllerPlus()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..addJavaScriptChannel(
                "ReactNativeWebView",
                onMessageReceived: (JavaScriptMessage jsMessage) {
                  print("Chatwoot message received: ${jsMessage.message}");
                  final message = getMessage(jsMessage.message);
                  if (isJsonString(message)) {
                    final parsedMessage = jsonDecode(message);
                    final eventType = parsedMessage["event"];
                    final type = parsedMessage["type"];
                    if (eventType == 'loaded') {
                      final authToken = parsedMessage["config"]["authToken"];
                      StoreHelper.storeCookie(authToken);
                      _controller?.runJavaScript(widget.injectedJavaScript);
                    }
                    if (type == 'close-widget') {
                      widget.closeWidget?.call();
                    }
                  }
                },
              )
              ..loadRequest(Uri.parse(webviewUrl));

        // if (Platform.isAndroid && widget.onAttachFile != null) {
        //   final androidController =
        //       _controller!.platform
        //           as webview_flutter_android.AndroidWebViewController;
        //   androidController.setOnShowFileSelector(
        //     (_) => widget.onAttachFile!.call(),
        //   );
        // }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null
        ? WebViewWidget(controller: _controller!)
        : SizedBox();
  }

  _goToUrl(String url) {
    launchUrl(Uri.parse(url));
  }
}
