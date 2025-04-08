import "dart:convert";
import 'package:crypto/crypto.dart';
import "/data/local/entity/chatwoot_user.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "constants.dart";

bool isJsonString(string) {
  try {
    jsonDecode(string);
  } catch (e) {
    return false;
  }
  return true;
}

String createWootPostMessage(object) {
  final stringfyObject = "${WOOT_PREFIX}${jsonEncode(object)}";
  final script = 'window.postMessage(\'${stringfyObject}\');';
  return script;
}

String getMessage(String data) {
  return data.replaceAll(WOOT_PREFIX, '');
}

String generateScripts({
  ChatwootUser? user,
  String? locale,
  dynamic customAttributes,
}) {
  String script = '';
  if (user != null) {
    final userObject = {
      "event": PostMessageEvents.SET_USER,
      "identifier": user.identifier,
      "user": user,
    };
    script += createWootPostMessage(userObject);
  }
  if (locale != null) {
    final localeObject = {
      "event": PostMessageEvents.SET_LOCALE,
      "locale": locale,
    };
    script += createWootPostMessage(localeObject);
  }
  if (customAttributes != null) {
    final attributeObject = {
      "event": PostMessageEvents.SET_CUSTOM_ATTRIBUTES,
      "customAttributes": customAttributes,
    };
    script += createWootPostMessage(attributeObject);
  }
  return script;
}

String generateIdentityToken({
  required String email,
  required String secret, // HMAC secret from Chatwoot
}) {
  var key = utf8.encode(secret);
  var bytes = utf8.encode(email);

  var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
  var digest = hmacSha256.convert(bytes);

  print("HMAC digest as hex string: $digest");

  return digest.toString();
}

const _androidOptions = AndroidOptions(encryptedSharedPreferences: true);
final secureStorage = new FlutterSecureStorage(aOptions: _androidOptions);
const cookieKey = 'cwCookie';

class StoreHelper {
  static Future<String> getCookie() async {
    final cookie = await secureStorage.read(key: cookieKey);
    return cookie ?? "";
  }

  static storeCookie(value) async {
    await secureStorage.write(key: cookieKey, value: value);
  }
}
