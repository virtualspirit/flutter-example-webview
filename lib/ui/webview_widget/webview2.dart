import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_project/ui/webview_widget/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/local/entity/chatwoot_user.dart';

class Webview extends StatefulWidget {
  late final String widgetUrl;
  late final String injectedJavaScript;

  final void Function()? closeWidget;
  final Future<List<String>> Function()? onAttachFile;
  final void Function()? onLoadStarted;
  final void Function(int)? onLoadProgress;
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
    widgetUrl = "$baseUrl/widget?website_token=$websiteToken";
    injectedJavaScript = generateScripts(
      user: user,
      locale: locale,
      customAttributes: customAttributes,
    );
  }

  @override
  State<Webview> createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  InAppWebViewController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String url = widget.widgetUrl;
      final cwCookie = await StoreHelper.getCookie();
      if (cwCookie.isNotEmpty) {
        url = "$url&cw_conversation=$cwCookie";
      }

      _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.widgetUrl)),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        iframeAllow: "camera; microphone",
        iframeAllowFullscreen: true,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
        controller.addJavaScriptHandler(
          handlerName: "ReactNativeWebView",
          callback: (args) {
            if (args.isNotEmpty) {
              final jsMessage = args[0];
              _handleJsMessage(jsMessage); // <- your function to handle message
            }
          },
        );
      },
      onLoadStart: (controller, url) {
        widget.onLoadStarted?.call();
      },
      onProgressChanged: (controller, progress) {
        widget.onLoadProgress?.call(progress);
      },
      onLoadStop: (controller, url) async {
        widget.onLoadCompleted?.call();
      },
      onConsoleMessage: (controller, msg) {
        printWrapped("Console: ${msg.message}");
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },
      shouldOverrideUrlLoading: (controller, navAction) async {
        final uri = navAction.request.url;
        if (uri != null && uri.toString().startsWith("http")) {
          await launchUrl(uri);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      // androidOnPermissionRequest: (controller, origin, resources) async {
      //   return PermissionRequestResponse(
      //     resources: resources,
      //     action: PermissionRequestResponseAction.GRANT,
      //   );
      // },
    );
  }

  void _handleJsMessage(dynamic messageData) {
    try {
      final msg = getMessage(messageData.toString());
      if (isJsonString(msg)) {
        final parsed = jsonDecode(msg);
        print('wew $parsed');
        final eventType = parsed["event"];
        final type = parsed["type"];
        if (eventType == "loaded") {
          final authToken = parsed["config"]["authToken"];
          print("authToken: $authToken");
          StoreHelper.storeCookie(authToken);
          _controller?.evaluateJavascript(source: widget.injectedJavaScript);
        }
        if (type == "close-widget") {
          widget.closeWidget?.call();
        }
      }
    } catch (e) {
      print("JS message parsing failed: $e");
    }
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
