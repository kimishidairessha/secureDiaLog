/// A model-view layer of home page including all needed services.
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

import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

import 'package:securedialog/model/geo_info.dart';
import 'package:securedialog/model/survey_day_info.dart';
import 'package:securedialog/model/survey_info.dart';
import 'package:securedialog/net/home_page_net.dart';
import 'package:securedialog/constants/app.dart';
import 'package:securedialog/utils/encrpt_utils.dart';
import 'package:securedialog/utils/geo_utils.dart';
import 'package:securedialog/utils/solid_utils.dart';
import 'package:securedialog/utils/survey_utils.dart';
import 'package:securedialog/utils/time_utils.dart';

/// A model-view layer for the home page including all needed services.

class HomePageService {
  final HomePageNet homePageNet = HomePageNet();

  /// Obtain a list of survey info from a POD.

  Future<List<SurveyDayInfo>?> getSurveyDayInfoList(
      int dayNum, Map<dynamic, dynamic>? authData) async {
    List<SurveyInfo> surveyInfoList = [];
    List<SurveyDayInfo> surveyDayInfoList = [];
    Map<String, dynamic> podInfo = SolidUtils.parseAuthData(authData);
    String? accessToken = podInfo[Constants.accessToken];
    String? webId = podInfo[Constants.webId];
    String? podURI = podInfo[Constants.podURI];
    String? containerURI = podInfo[Constants.containerURI];
    String? surveyContainerURI = podInfo[Constants.surveyContainerURI];
    dynamic rsa = podInfo[Constants.rsa];
    dynamic pubKeyJwk = podInfo[Constants.pubKeyJwk];

    EncryptClient? encryptClient =
        await EncryptUtils.getClient(authData!, webId!);
    try {
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(podURI!, accessToken!, rsa, pubKeyJwk),
          Constants.containerName)) {
        return null;
      }

      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(
              containerURI!, accessToken, rsa, pubKeyJwk),
          Constants.surveyContainerName)) {
        return null;
      }

      String surveyContainerContent = await homePageNet.readFile(
          surveyContainerURI!, accessToken, rsa, pubKeyJwk);

      List<String> fileNameList = SolidUtils.getSurveyFileNameList(
          surveyContainerContent, webId, 2147483647);

      for (int i = 0; i < fileNameList.length; i++) {
        String fileName = fileNameList[i];
        String fileURI = surveyContainerURI + fileName;
        String fileContent =
            await homePageNet.readFile(fileURI, accessToken, rsa, pubKeyJwk);
        SurveyInfo surveyInfo =
            SolidUtils.parseSurveyFile(fileContent, encryptClient!);
        surveyInfoList.add(surveyInfo);
      }
    } catch (e) {
      debugPrint("Error on fetching survey data: $e");
      return null;
    }

    // Transform from surveyInfoList to surveyDayInfoList.

    Map<String, List<SurveyInfo>> tempMap = {};

    for (SurveyInfo surveyInfo in surveyInfoList) {
      String obTime = surveyInfo.obTime;

      String date = obTime.length < 8 ? obTime : obTime.substring(0, 8);

      if (!tempMap.containsKey(date)) {
        List<SurveyInfo> tempList = [];
        tempList.add(surveyInfo);
        tempMap[date] = tempList;
      } else {
        List<SurveyInfo> tempList = tempMap[date]!;
        tempList.add(surveyInfo);
        tempMap[date] = tempList;
      }
    }

    tempMap.forEach((date, surveyInfoList) {
      SurveyDayInfo surveyDayInfo = SurveyDayInfo();
      surveyDayInfo.date = date;
      surveyDayInfo.surveyInfoList = surveyInfoList;
      surveyDayInfoList.add(surveyDayInfo);
    });

    // Sorting.

    surveyDayInfoList.sort((s1, s2) => s1.date.compareTo(s2.date));

    return surveyDayInfoList;
  }

  Future<void> deleteFileMatchingCriteria(
      Map<dynamic, dynamic>? authData, String criteria) async {
    Map<String, dynamic> podInfo = SolidUtils.parseAuthData(authData);
    String? accessToken = podInfo[Constants.accessToken];
    String? surveyContainerURI = podInfo[Constants.surveyContainerURI];
    dynamic rsa = podInfo[Constants.rsa];
    dynamic pubKeyJwk = podInfo[Constants.pubKeyJwk];

    try {
      String surveyContainerContent = await homePageNet.readFile(
          surveyContainerURI!, accessToken!, rsa, pubKeyJwk);

      List<String> fileNameList = SolidUtils.getSurveyFileNameList(
          surveyContainerContent, podInfo[Constants.webId], 2147483647);

      for (String fileName in fileNameList) {
        if (fileName.startsWith(criteria)) {
          String fileURI = surveyContainerURI + fileName;
          await homePageNet.deleteFile(fileURI, accessToken, rsa, pubKeyJwk);
        }
      }
    } catch (e) {
      debugPrint("Error on deleting file matching criteria: $e");
    }
  }

  /// the method is to save the answered survey information into a POD
  /// @param answer1 - q1's answer
  ///        answer2 - q2's answer
  ///        answer3 - q3's answer
  ///        answer4 - q4's answer
  ///        answer5 - q5's answer
  ///        answer6 - q6's answer
  ///        answer7 - q7's answer
  ///        authData - the authentication Data received after login
  ///        dateTime - the timestamp collected when submitting the survey
  /// @return isSuccess - TRUE is success and FALSE is failure
  Future<bool> saveSurveyInfo(
      String answer1,
      String answer2,
      String answer3,
      String answer4,
      String answer5,
      String answer6,
      String answer7,
      Map<dynamic, dynamic>? authData,
      DateTime dateTime) async {
    Map<String, dynamic> podInfo = SolidUtils.parseAuthData(authData);
    String? accessToken = podInfo[Constants.accessToken];
    String? webId = podInfo[Constants.webId];
    String? podURI = podInfo[Constants.podURI];
    String? containerURI = podInfo[Constants.containerURI];
    String? surveyContainerURI = podInfo[Constants.surveyContainerURI];
    dynamic rsa = podInfo[Constants.rsa];
    dynamic pubKeyJwk = podInfo[Constants.pubKeyJwk];
    EncryptClient? encryptClient =
        await EncryptUtils.getClient(authData!, webId!);
    Map<String, String> surveyInfo = await SurveyUtils.getFormattedSurvey(
        answer1,
        answer2,
        answer3,
        answer4,
        answer5,
        answer6,
        answer7,
        dateTime,
        encryptClient!);
    try {
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(podURI!, accessToken!, rsa, pubKeyJwk),
          Constants.containerName)) {
        await homePageNet.mkdir(
            podURI, accessToken, rsa, pubKeyJwk, Constants.containerName);
      }
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(
              containerURI!, accessToken, rsa, pubKeyJwk),
          Constants.surveyContainerName)) {
        await homePageNet.mkdir(containerURI, accessToken, rsa, pubKeyJwk,
            Constants.surveyContainerName);
      }
      String curSurveyFileName = TimeUtils.getFormattedTimeYYYYmmDD(dateTime) +
          TimeUtils.getFormattedTimeHHmmSS(dateTime);
      await homePageNet.touch(
          surveyContainerURI!, accessToken, rsa, pubKeyJwk, curSurveyFileName);
      String curRecordFileURI = SolidUtils.genCurRecordFileURI(
          surveyContainerURI, curSurveyFileName, webId);
      String sparqlQuery;
      String predicate;
      // start saving
      surveyInfo.forEach((subject, value) async {
        predicate = SolidUtils.genPredicate(subject);
        sparqlQuery = SolidUtils.genSparqlQuery(
            Constants.insert, webId, predicate, surveyInfo[subject]!, null);
        await homePageNet.updateFile(
            curRecordFileURI, accessToken, rsa, pubKeyJwk, sparqlQuery);
      });
      setLastSurveyTime(
          podInfo, TimeUtils.getFormattedTimeYYYYmmDDHHmmSS(dateTime));
    } catch (e) {
      debugPrint("Error on saving survey information: $e");
      return false;
    }
    return true;
  }

  Future<void> setLastSurveyTime(
      Map<String, dynamic> podInfo, String obTime) async {
    String? accessToken = podInfo[Constants.accessToken];
    String? webId = podInfo[Constants.webId];
    String? containerURI = podInfo[Constants.containerURI];
    dynamic rsa = podInfo[Constants.rsa];
    dynamic pubKeyJwk = podInfo[Constants.pubKeyJwk];
    if (!SolidUtils.isFileExist(
        await homePageNet.readFile(containerURI!, accessToken!, rsa, pubKeyJwk),
        Constants.commonFileName)) {
      await homePageNet.touch(
          containerURI, accessToken, rsa, pubKeyJwk, Constants.commonFileName);
    }
    String commonFileURI = SolidUtils.genCurRecordFileURI(
        containerURI, Constants.commonFileName, webId!);
    String content =
        await homePageNet.readFile(commonFileURI, accessToken, rsa, pubKeyJwk);
    String? lastObTime = SolidUtils.getLastObTime(content);
    String subject = Constants.lastObTimeKey;
    String predicate = SolidUtils.genPredicate(subject);
    String sparqlQuery;
    if (lastObTime == null) {
      sparqlQuery = SolidUtils.genSparqlQuery(
          Constants.insert, subject, predicate, obTime, null);
    } else {
      sparqlQuery = SolidUtils.genSparqlQuery(
          Constants.update, subject, predicate, obTime, lastObTime);
    }
    await homePageNet.updateFile(
        commonFileURI, accessToken, rsa, pubKeyJwk, sparqlQuery);
  }

  Future<String> getLastSurveyTime(Map<dynamic, dynamic> authData) async {
    Map<String, dynamic> podInfo = SolidUtils.parseAuthData(authData);
    String? accessToken = podInfo[Constants.accessToken];
    String? webId = podInfo[Constants.webId];
    String? podURI = podInfo[Constants.podURI];
    String? containerURI = podInfo[Constants.containerURI];
    dynamic rsa = podInfo[Constants.rsa];
    dynamic pubKeyJwk = podInfo[Constants.pubKeyJwk];
    try {
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(podURI!, accessToken!, rsa, pubKeyJwk),
          Constants.containerName)) {
        return Constants.none;
      }
      if (!SolidUtils.isFileExist(
          await homePageNet.readFile(
              containerURI!, accessToken, rsa, pubKeyJwk),
          Constants.commonFileName)) {
        return Constants.none;
      }
      String commonFileURI = SolidUtils.genCurRecordFileURI(
          containerURI, Constants.commonFileName, webId!);
      String content = await homePageNet.readFile(
          commonFileURI, accessToken, rsa, pubKeyJwk);
      String? lastObTime = SolidUtils.getLastObTime(content);
      if (lastObTime == null) {
        return Constants.none;
      }
      return lastObTime;
    } catch (e) {
      debugPrint("Error on fetching lastObTime: $e");
      return Constants.none;
    }
  }

  /// Save geographical information into a POD where [latLng] is the location
  /// collected from the device, [authData] is the authentication data received
  /// after login, and [dateTime] is the timestamp. It returns a [bool]
  /// indicating success.

  Future<bool> saveGeoInfo(
    LatLng latLng,
    Map<dynamic, dynamic>? authData,
    DateTime dateTime,
  ) async {
    // ignore: dead_code
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? captureLocation = prefs.getBool('captureLocation');
    if (captureLocation == null || !captureLocation) {
      return false; // Don't save if location capture is off
    }
    Map<String, dynamic> podInfo = SolidUtils.parseAuthData(authData);
    String? accessToken = podInfo[Constants.accessToken];
    String? webId = podInfo[Constants.webId];
    String? podURI = podInfo[Constants.podURI];
    String? containerURI = podInfo[Constants.containerURI];
    String? geoContainerURI = podInfo[Constants.geoContainerURI];
    dynamic rsa = podInfo[Constants.rsa];
    dynamic pubKeyJwk = podInfo[Constants.pubKeyJwk];
    EncryptClient? encryptClient =
        await EncryptUtils.getClient(authData!, webId!);

    Map<String, String> positionInfo =
        await GeoUtils.getFormattedPosition(latLng, dateTime, encryptClient!);
    try {
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(podURI!, accessToken!, rsa, pubKeyJwk),
          Constants.containerName)) {
        await homePageNet.mkdir(
            podURI, accessToken, rsa, pubKeyJwk, Constants.containerName);
      }
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(
              containerURI!, accessToken, rsa, pubKeyJwk),
          Constants.geoContainerName)) {
        await homePageNet.mkdir(containerURI, accessToken, rsa, pubKeyJwk,
            Constants.geoContainerName);
      }
      String todayContainerName = TimeUtils.getFormattedTimeYYYYmmDD(dateTime);
      // todayContainerName = EncryptUtils.encode(todayContainerName, encryptClient)!.replaceAll("=", "%3D");
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(
              geoContainerURI!, accessToken, rsa, pubKeyJwk),
          todayContainerName)) {
        await homePageNet.mkdir(
            geoContainerURI, accessToken, rsa, pubKeyJwk, todayContainerName);
      }
      String todayContainerURI = "$geoContainerURI$todayContainerName/";
      String curRecordFileName = TimeUtils.getFormattedTimeHHmmSS(dateTime);
      // curRecordFileName = EncryptUtils.encode(curRecordFileName, encryptClient)!.replaceAll("=", "%3D");
      await homePageNet.touch(
          todayContainerURI, accessToken, rsa, pubKeyJwk, curRecordFileName);
      String curRecordFileURI = SolidUtils.genCurRecordFileURI(
          todayContainerURI, curRecordFileName, webId);
      String sparqlQuery;
      String predicate;
      // start saving
      positionInfo.forEach((subject, value) async {
        predicate = SolidUtils.genPredicate(subject);
        sparqlQuery = SolidUtils.genSparqlQuery(
            Constants.insert, webId, predicate, positionInfo[subject]!, null);
        await homePageNet.updateFile(
            curRecordFileURI, accessToken, rsa, pubKeyJwk, sparqlQuery);
      });
    } catch (e) {
      debugPrint("Error on saving geographical information: $e");
      return false;
    }
    return true;
  }

  /// the method is to save the geographical information into a POD after recovering from a background status
  /// @param geoInfo - the geo info model
  ///        authData - the authentication Data received after login
  /// @return isSuccess - TRUE is success and FALSE is failure
  Future<bool> saveBgGeoInfo(
      Map<dynamic, dynamic>? authData, GeoInfo geoInfo) async {
    Map<String, dynamic> podInfo = SolidUtils.parseAuthData(authData);
    String? accessToken = podInfo[Constants.accessToken];
    String? webId = podInfo[Constants.webId];
    String? podURI = podInfo[Constants.podURI];
    String? containerURI = podInfo[Constants.containerURI];
    String? geoContainerURI = podInfo[Constants.geoContainerURI];
    dynamic rsa = podInfo[Constants.rsa];
    dynamic pubKeyJwk = podInfo[Constants.pubKeyJwk];
    EncryptClient? encryptClient =
        await EncryptUtils.getClient(authData!, webId!);
    try {
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(podURI!, accessToken!, rsa, pubKeyJwk),
          Constants.containerName)) {
        await homePageNet.mkdir(
            podURI, accessToken, rsa, pubKeyJwk, Constants.containerName);
      }
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(
              containerURI!, accessToken, rsa, pubKeyJwk),
          Constants.geoContainerName)) {
        await homePageNet.mkdir(containerURI, accessToken, rsa, pubKeyJwk,
            Constants.geoContainerName);
      }
      String todayContainerName = geoInfo.date;
      if (!SolidUtils.isContainerExist(
          await homePageNet.readFile(
              geoContainerURI!, accessToken, rsa, pubKeyJwk),
          todayContainerName)) {
        await homePageNet.mkdir(
            geoContainerURI, accessToken, rsa, pubKeyJwk, todayContainerName);
      }
      String todayContainerURI = "$geoContainerURI$todayContainerName/";
      String curRecordFileName = geoInfo.time;
      await homePageNet.touch(
          todayContainerURI, accessToken, rsa, pubKeyJwk, curRecordFileName);
      String curRecordFileURI = SolidUtils.genCurRecordFileURI(
          todayContainerURI, curRecordFileName, webId);
      String sparqlQuery;
      String predicate;
      Map<String, String> positionInfo =
          await GeoUtils.getFormattedPositionFromGeoInfo(
              geoInfo, encryptClient!);
      // start saving
      positionInfo.forEach((subject, value) async {
        predicate = SolidUtils.genPredicate(subject);
        sparqlQuery = SolidUtils.genSparqlQuery(
            Constants.insert, webId, predicate, positionInfo[subject]!, null);
        await homePageNet.updateFile(
            curRecordFileURI, accessToken, rsa, pubKeyJwk, sparqlQuery);
      });
    } catch (e) {
      debugPrint("Error on saving geographical information: $e");
      return false;
    }
    return true;
  }

  /// the method is to log out from a logged-in status, once log out, users need to reenter the username and password
  /// @param logoutUrl - the logout url parsed from authentication data
  /// @return void
  Future<void> logout(String logoutURL) async {
    EncryptUtils.revoke();
    homePageNet.logout(logoutURL);
  }
}
