import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_project/data/local/entity/chatwoot_user.dart';
import 'package:my_project/ui/webview_widget/utils.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

  late ChatwootUser userC;
  late String webToken;
  late String url;

  Webview({
    Key? key,
    required String websiteToken,
    required String baseUrl,
    required ChatwootUser user,
    String locale = "en",
    customAttributes,
    this.closeWidget,
    this.onAttachFile,
    this.onLoadStarted,
    this.onLoadProgress,
    this.onLoadCompleted,
  }) : super(key: key) {
    widgetUrl = "$baseUrl/widget?website_token=${websiteToken}";

    injectedJavaScript = generateScripts(
      user: user,
      locale: locale,
      customAttributes: customAttributes,
    );
    userC = user;
    webToken = websiteToken;
    url = baseUrl;
  }

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(widget.widgetUrl)),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    controller.addJavaScriptHandler(
                      handlerName: 'chatwootClosed',
                      callback: (args) {
                        // Tutup aplikasi Flutter
                        SystemNavigator.pop(); // atau exit(0) jika mau paksa keluar
                      },
                    );
                  },
                  onLoadStop: (controller, url) async {
                    await controller.evaluateJavascript(
                      source: """

                        window.chatwootSettings = {
                          hideMessageBubble: true,
                        };

                        (function(d,t) {
                            var BASE_URL="${widget.url}";
                            var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
                            g.src=BASE_URL+"/packs/js/sdk.js";
                            g.defer = true;
                            g.async = true;
                            s.parentNode.insertBefore(g,s);
                            g.onload=function(){
                              window.chatwootSDK.run({
                                websiteToken: '${widget.webToken}',
                                baseUrl: BASE_URL
                              })
                            }
                          })(document,"script");

                          setTimeout(() => {
                            \$chatwoot.setUser("${widget.userC.identifier}", {
                              name: "${widget.userC.name}",
                              identifier_hash: "${widget.userC.identifierHash}"
                            });


                            window.addEventListener("close-widget", function() {
                              window.flutter_inappwebview.callHandler('chatwootClosed');
                            });

                           
                            \$chatwoot.toggle('open');

                            \$chatwoot.toggleBubbleVisibility("hide");
                          }, 1000);
                        """,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
