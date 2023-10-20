/// Provide a utility class for managing solid server operations
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
/// Authors: Bowen Yang, Ye Duan, Graham Williams

import 'package:flutter/material.dart' show debugPrint;

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:securedialog/model/survey_info.dart';
import 'package:securedialog/utils/constants.dart';
import 'package:securedialog/utils/encrpt_utils.dart';
import 'package:rdflib/rdflib.dart';
import 'package:securedialog/utils/global.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

/// A class supporting solid server activities.

class SolidUtils {
  static String? getLastObTime(String content) {
    List<String> lines = content.split("\n");
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.trim() == "") {
        continue;
      }
      if (line.contains(Constants.lastObTimeKey)) {
        return line
            .split(" \"")[1]
            .replaceAll("\".", "")
            .replaceAll("\";", "")
            .trim();
      }
    }
    return null;
  }

  static SurveyInfo parseSurveyFile(
      String content, EncryptClient encryptClient) {
    SurveyInfo surveyInfo = SurveyInfo();
    List<String> lines = content.split("\n");

    // 20231001 kimi encryption and decryption do not match, it will throw
    // error, when decrypting.
    //20231005 kimi Modify the method without changing the type to avoid
    // excessive modification.
    // String testString = "Hello, world!";
    // print("TESTING: test string: $testString");
    // // String encrypted = EncryptUtils.encode(testString, encryptClient)!;
    // List encryptRes = encryptClient.encryptVal(Global.encryptKey, testString);
    //
    // String encryptVal = encryptRes[0];
    // String ivVal = encryptRes[1];
    //
    // print("TESTING: encrypted: $encryptVal");
    // print("TESTING: ivVal: $ivVal");
    //
    // // check why the decryption cannot work
    //
    // print("TESTING: encryption key: ${Global.encryptKey}");
    //
    // String encryption = '${encryptRes[0]}:::${encryptRes[1]}';
    // List<String> parts = encryption.split(':::');
    // if (parts.length != 2) {
    //   throw ArgumentError('Invalid encoded string format');
    // }
    // String encryptVal1 = parts[0];
    // String ivVal1 = parts[1];
    //
    // String decrypted;
    // try {
    //   // ORIGINALLY IT WAS THIS:      decrypted = EncryptUtils.decode(encrypted, encryptClient)!;
    //   decrypted =
    //       encryptClient.decryptVal(Global.encryptKey, encryptVal1, ivVal1);
    //   print("TESTING: decrypted: $decrypted");
    //   print(decrypted == testString
    //       ? "SUCCESSFULLY DESCRYPTED\n"
    //       : "FAILED TO DECRYPT\n");
    // } catch (e, stackTrace) {
    //   print("Error during decryption: $e");
    //   print("StackTrace: $stackTrace");
    // }

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String val = "";
      String key = "";

      // 20230930 gjw TODO CAN WE PRINT THE DECODED LINE HERE???? THIS WILL HELP
      // UNDERSTAND WHY NO obTime IS FOUND PERHAPS? WOULD ALSO PROBABLY BE A
      // BETTER APPROACH THAN ALL OF THE ENCODE AND DECODE CALLS BELOW.

      // 20231001 gjw TODO USE THE RDF PACKAGE TO HANDLE THE TTL.

      if (line.contains(" \"")) {
        key = line.split(" \"")[0];
        val = line.split(" \"")[1];
      } else {
        continue;
      }

      key = key.split("http://xmlns.com/foaf/0.1/").last;
      key = key.substring(0, key.length - 1); // remove the last character
      key = EncryptUtils.decode(key, encryptClient)!;

      // 20230930 gjw TODO WHY IS THE Q1KEY DIFFERENT FOR EACH LINE?

      // 20230930 gjw TODO THERE IS WAY TO MUCH REPEATED CODE BELOW. NEEDS
      // FIXING. DRY => DON'T REPEAT YOURSELF

      // 20231004 gjw TODO REPLACE THE Q1, Q2, ETC WITH MORE SENSIBLE NAMES -
      // THEY MEAN NOTHING.

      if (Constants.q1Key == key) {
        surveyInfo.setStrength(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      } else if (Constants.q2Key == key) {
        surveyInfo.setFasting(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      } else if (Constants.q3Key == key) {
        surveyInfo.setPostprandial(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      } else if (Constants.q4Key == key) {
        surveyInfo.setSystolic(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      } else if (Constants.q5Key == key) {
        surveyInfo.setDiastolic(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      } else if (Constants.q6Key == key) {
        surveyInfo.setWeight(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      } else if (Constants.q7Key == key) {
        surveyInfo.setHeartRate(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      } else if (Constants.obTimeKey == key) {
        surveyInfo.setObTime(EncryptUtils.decode(
            val.replaceAll("\".", "").replaceAll("\";", "").trim(),
            encryptClient)!);
      }
    }

    return surveyInfo;
  }

  static List<String> getSurveyFileNameList(
      String content, String webId, int num) {
    List<String> nameList = [];
    if (_isSolidCommunityHost(webId)) {
      // solid community needs to be parsed differently
      List<String> lines = content.split("\n");
      for (int i = lines.length - 1; i >= 0 && nameList.length < num; i--) {
        String line = lines[i];
        if (line.contains(".ttl>") && !line.contains(".ttl>,")) {
          String fileName = line.substring(1, 19);
          nameList.insert(0, fileName);
        }
      }
    } else {
      Graph graph = Graph();
      graph.parseTurtle(content);
      graph.groups.forEach((key, value) {
        if (nameList.length >= num) {
          return;
        }
        if (key.value.trim() != "") {
          nameList.add(key.value);
        }
      });
    }
    return nameList;
  }

  /// check if the container the app need to use is already exist, if it is, no need to create
  /// a new one, if not, the app need to create a new container
  /// @param content - the content read from the directory of the POD
  /// @param name - specific container name of being checked
  /// @return isExist - TRUE means it exists, FALSE means not
  static bool isContainerExist(String content, String name) {
    return content.contains("$name/") ||
        content.contains("@prefix $name: </$name/>.");
  }

  /// check if the file the app need to use is already exist, if it is, no need to create
  /// a new one, if not, the app need to create a new file
  /// @param content - the content read from the directory of the POD
  /// @param name - specific file name of being checked
  /// @return isExist - TRUE means it exists, FALSE means not
  static bool isFileExist(String content, String name) {
    return content.contains("<$name>") || content.contains("<$name.ttl>");
  }

  /// parse the received authentication data into a map data structure to reduce the repeated parsing
  /// and make it easier to use during the business logic
  /// @param authData - the authentication data get from login procedure
  /// @return parsedAuthData - a <String, dynamic> map that contains necessary data parsed from the original authentication data
  static Map<String, dynamic> parseAuthData(Map<dynamic, dynamic>? authData) {
    String accessToken = authData![Constants.accessToken];
    String webId =
        JwtDecoder.decode(accessToken)[Constants.webId.toLowerCase()];
    String podURI = webId.substring(0, webId.length - 15);
    String containerURI = podURI + Constants.relativeContainerURI;
    String geoContainerURI = containerURI + Constants.relativeGeoContainerURI;
    String surveyContainerURI =
        containerURI + Constants.relativeSurveyContainerURI;
    dynamic rsa = authData[Constants.rsaInfo][Constants.rsa];
    dynamic pubKeyJwk = authData[Constants.rsaInfo][Constants.pubKeyJwk];
    return <String, dynamic>{
      Constants.accessToken: accessToken,
      Constants.webId: webId,
      Constants.rsa: rsa,
      Constants.pubKeyJwk: pubKeyJwk,
      Constants.podURI: podURI,
      Constants.containerURI: containerURI,
      Constants.geoContainerURI: geoContainerURI,
      Constants.surveyContainerURI: surveyContainerURI,
    };
  }

  /// generate a sparql query based on given information
  /// @param action - the action of this sparql query, INSERT/DELETE/UPDATE
  ///        subject - subject in a sparql query
  ///        predicate - predicate in a sparql query
  ///        object - object in a sparql query
  ///        prevObject - only applied to UPDATE action, when updating, the app needs to delete
  ///                     the previous data and insert a new one, so it is necessary to provide
  ///                     a previous value in this query, otherwise will receive a 409 (conflict)
  ///                     error status code
  /// @return sparqlQuery - a sparql query in string format
  static String genSparqlQuery(String action, String subject, String predicate,
      String object, String? prevObject) {
    String query;
    switch (action) {
      case Constants.insert:
        query = "INSERT DATA {<$subject> <$predicate> \"$object\"}";
        break;
      case Constants.delete:
        query = "DELETE DATA {<$subject> <$predicate> \"$object\"}";
        break;
      case Constants.update:
        query =
            "DELETE DATA {<$subject> <$predicate> \"$prevObject\"}; INSERT DATA {<$subject> <$predicate> \"$object\"}";
        break;
      default:
        throw Exception("Invalid action");
    }
    return query;
  }

  /// generate predicate that will be used in genSparqlQuery() method
  /// @param attribute - the attribute user would like to modify
  /// @return predicate - generated predicate
  static String genPredicate(String attribute) {
    return Constants.predicate + attribute;
  }

  /// generate curRecordFileName that will be used in saveSurveyInfo() method
  /// @param todayContainerURI - today's container URI
  ///        curRecordFileName - the record-file-name at this time
  ///        webId - user's webId
  /// @return curRecordFileURI - generated record-file-URI at this time
  static String genCurRecordFileURI(
      String todayContainerURI, String curRecordFileName, String webId) {
    if (_isSolidCommunityHost(webId)) {
      return todayContainerURI + curRecordFileName + Constants.ttlSuffix;
    } else {
      return todayContainerURI + curRecordFileName;
    }
  }

  static bool _isSolidCommunityHost(String webId) {
    return webId.contains("solidcommunity");
  }
}
