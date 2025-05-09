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
    widgetUrl =
        "$baseUrl/widget?website_token=${websiteToken}&locale=${locale}";

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
                        (function(d,t) {
                        document.head.insertAdjacentHTML('beforeend', '<style>.woot--close img { display: none; } #woot-widget-bubble-icon { display: none; }</style>');
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
                              email: "${widget.userC.email}",
                              name: "${widget.userC.name}",
                              identifier_hash: "${widget.userC.identifierHash}"
                            });

                            \$chatwoot.toggle('open');

                            window.addEventListener("close-widget", function() {
                              console.log('wew')
                              window.flutter_inappwebview.callHandler('chatwootClosed');
                            });

                            window.addEventListener('chatwoot:on-message', function(e) {
                              console.log('chatwoot:on-message', e.detail)
                            })

                            window.\$chatwoot.toggleBubbleVisibility("hide");
                          }, 300);
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
