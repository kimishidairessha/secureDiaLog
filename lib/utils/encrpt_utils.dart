/// Provide a utility class for managing encryption-related operations
///
/// Copyright (C) 2023 The Authors
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Bowen Yang, Ye Duan

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

import 'global.dart';

class EncryptUtils {
  static EncryptClient? _client;

  static Future<EncryptClient?> getClient(Map authData, String webId) async {
    return _client;
  }

  static Future<bool> checkAndSet(
      Map authData, String encKeyText, String webId) async {
    try {
      _client ??= EncryptClient(authData, webId);
      String encKey =
          sha256.convert(utf8.encode(encKeyText)).toString().substring(0, 32);
      if (await _client!.checkEncSetup() == false) {
        await _client?.setupEncKey(encKey);
        Global.encryptKey = encKey;
        return true;
      } else {
        if (await _client!.verifyEncKey(encKey)) {
          Global.encryptKey = encKey;
          return true;
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> revoke() async {
    if (_client == null) {
      return;
    }
    await _client?.revokeEnc(Global.encryptKey);
    _client == null;
  }

  static String? encode(String text, EncryptClient encryptClient) {
    // 20231004 gjw TODO NEEDS TO BE UPDATED SINCE WE NEED THE ivVal
    // String ivVal = encryptClient.encryptVal(Global.encryptKey, text)[1];
    // return encryptClient.encryptVal(Global.encryptKey, text)[0];
    List encryptionResults = encryptClient.encryptVal(Global.encryptKey, text);
    return '${encryptionResults[0]}:::${encryptionResults[1]}';
  }

  static String? decode(String code, EncryptClient encryptClient) {
    List<String> parts = code.split(':::');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encoded string format');
    }
    String encryptedText = parts[0];
    String ivVal = parts[1];
    return encryptClient.decryptVal(Global.encryptKey, encryptedText, ivVal);
    // 20231004 gjw TODO NEEDS TO BE UPDATED SINCE WE NEED THE ivVal
  }
}
