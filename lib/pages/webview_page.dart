import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:my_project/chatwoot_callbacks.dart';
import 'package:my_project/chatwoot_client.dart';
import 'package:my_project/data/local/entity/chatwoot_user.dart';
import 'package:my_project/ui/webview_widget/chatwoot_widget.dart';
import 'package:my_project/ui/webview_widget/utils.dart';
import 'package:path_provider/path_provider.dart';

class WebViewPage extends StatefulWidget {
  final String name;
  final String email;

  const WebViewPage({super.key, required this.name, required this.email});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String identityToken = '';

  @override
  void initState() {
    super.initState();
    identityToken = generateIdentityToken(
      email: widget.email,
      secret: 'E7U8pqpdrXnf98jksRsYrrvb',
    );
    // 6yf9yLWC95yaM6JDNNB1Ttxq
    print('wew $identityToken');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatwoot Example")),
      // ZpvmAHn5z3o4AYtojcWNvMPd xingchen
      // v8pLycCQY7CJKqM8gSLDEocP# virtualspirit
      body: ChatwootWidget(
        websiteToken: "ZpvmAHn5z3o4AYtojcWNvMPd",
        baseUrl: "https://virtualchat.virtualspirit.me/",
        user: ChatwootUser(
          identifier: widget.email,
          identifierHash: identityToken,
          name: widget.name,
          email: widget.email,
        ),
        locale: "en",
        closeWidget: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        },
        onAttachFile: _filePicker,
        onLoadStarted: () {
          print("loading widget");
        },
        onLoadProgress: (int progress) {
          print("loading... ${progress}");
        },
        onLoadCompleted: () {
          print("widget loaded");
        },
      ),
    );
  }

  Future<List<String>> _filePicker() async {
    final picker = image_picker.ImagePicker();
    final photo = await picker.pickImage(
      source: image_picker.ImageSource.gallery,
    );

    if (photo == null) {
      return [];
    }

    final imageData = await photo.readAsBytes();
    final decodedImage = image.decodeImage(imageData);
    final scaledImage = image.copyResize(decodedImage!, width: 500);
    final jpg = image.encodeJpg(scaledImage, quality: 90);

    final filePath = (await getTemporaryDirectory()).uri.resolve(
      './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    final file = await File.fromUri(filePath).create(recursive: true);
    await file.writeAsBytes(jpg, flush: true);

    return [file.uri.toString()];
  }
}
