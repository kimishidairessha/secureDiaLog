/// Provide a utility class for managing survey operations
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
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:securedialog/utils/encrpt_utils.dart';
import 'package:securedialog/utils/global.dart';
import 'package:securedialog/utils/time_utils.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:solid_encrypt/solid_encrypt.dart';

import 'package:securedialog/constants/app.dart';

/// this class is a util class related to survey affairs
class SurveyUtils {
  /// check if a string complies with fasting blood glucose format,
  /// a fasting blood glucose input format is XX.X or XX and it should <= 1000.0 && >= 30.0
  /// @param fastingText - a string text of fasting blood glucose
  /// @return isValid - TRUE means it valid, FALSE means not
  static bool checkFastingBloodGlucoseText(String fastingText) {
    if (fastingText.trim() == "") {
      return true;
    }
    if (fastingText.endsWith(".")) {
      return false;
    }
    double fasting;
    try {
      fasting = double.parse(fastingText);
      if (fasting < 30.0 || fasting > 1000.0) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// check if a string complies with postprandial blood glucose format,
  /// a postprandial blood glucose input format is XX.X or XX and it should <= 1000.0 && >= 30.0
  /// @param postprandialText - a string text of postprandial blood glucose
  /// @return isValid - TRUE means it valid, FALSE means not
  static bool checkPostprandialBloodGlucoseText(String postprandialText) {
    if (postprandialText.trim() == "") {
      return true;
    }
    if (postprandialText.endsWith(".")) {
      return false;
    }
    double postprandial;
    try {
      postprandial = double.parse(postprandialText);
      if (postprandial < 30.0 || postprandial > 1000.0) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// check if a string complies with systolic format,
  /// a systolic format is a 2 or 3-digits integer and it should <= 220 && >= 50
  /// @param systolicText - a string text of systolic
  /// @return isValid - TRUE means it valid, FALSE means not
  static bool checkSystolicText(String systolicText) {
    if (systolicText.trim() == "") {
      return true;
    }
    int systolic;
    try {
      systolic = int.parse(systolicText);
      if (systolic < 50 || systolic > 220) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// check if a string complies with diastolic format,
  /// a diastolic format is a 2 or 3-digits integer and it should <= 160 && >= 30
  /// @param diastolicText - a string text of diastolic
  /// @return isValid - TRUE means it valid, FALSE means not
  static bool checkDiastolicText(String diastolicText) {
    if (diastolicText.trim() == "") {
      return true;
    }
    int diastolic;
    try {
      diastolic = int.parse(diastolicText);
      if (diastolic < 30 || diastolic > 160) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// check if a string complies with weight format,
  /// a weight format is is XX.X or XX and it should <= 500.0 && >= 10.0
  /// @param weightText - a string text of weight
  /// @return isValid - TRUE means it valid, FALSE means not
  static bool checkWeightText(String weightText) {
    if (weightText.trim() == "") {
      return true;
    }
    if (weightText.endsWith(".")) {
      return false;
    }
    double weight;
    try {
      weight = double.parse(weightText);
      if (weight < 10.0 || weight > 500.0) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// check if a string complies with diastolic format,
  /// a heart rate format is a 2 or 3-digits integer and it should <= 260 && >= 30
  /// @param heartRateText - a string text of heart rate
  /// @return isValid - TRUE means it valid, FALSE means not
  static bool checkHeartRateText(String heartRateText) {
    if (heartRateText.trim() == "") {
      return true;
    }
    int heartRate;
    try {
      heartRate = int.parse(heartRateText);
      if (heartRate < 30 || heartRate > 260) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// get a map of formatted survey information for further processing
  /// @param answer1 - q1's answer
  ///        answer2 - q2's answer
  ///        answer3 - q3's answer
  ///        answer4 - q4's answer
  ///        answer5 - q5's answer
  ///        answer6 - q6's answer
  ///        answer7 - q7's answer
  ///        dateTime - time of survey submitting
  /// @return surveyMap - K-V structure to make further process more convenient
  static Future<Map<String, String>> getFormattedSurvey(
      String answer1,
      String answer2,
      String answer3,
      String answer4,
      String answer5,
      String answer6,
      String answer7,
      DateTime dateTime,
      EncryptClient encryptClient) async {
    String? deviceInfo = await PlatformDeviceId.getDeviceId;
    if ((deviceInfo == null || deviceInfo.trim() == "") && Platform.isLinux) {
      deviceInfo = DeviceInfoPlugin().linuxInfo.toString();
    }
    String q1Key = EncryptUtils.encode(Constants.q1Key, encryptClient)!;
    String q2Key = EncryptUtils.encode(Constants.q2Key, encryptClient)!;
    String q3Key = EncryptUtils.encode(Constants.q3Key, encryptClient)!;
    String q4Key = EncryptUtils.encode(Constants.q4Key, encryptClient)!;
    String q5Key = EncryptUtils.encode(Constants.q5Key, encryptClient)!;
    String q6Key = EncryptUtils.encode(Constants.q6Key, encryptClient)!;
    String q7Key = EncryptUtils.encode(Constants.q7Key, encryptClient)!;
    String deviceKey = EncryptUtils.encode(Constants.deviceKey, encryptClient)!;
    String obTimeKey = EncryptUtils.encode(Constants.obTimeKey, encryptClient)!;
    String latitudeKey =
        EncryptUtils.encode(Constants.latitudeKey, encryptClient)!;
    String longitudeKey =
        EncryptUtils.encode(Constants.longitudeKey, encryptClient)!;
    if (Global.globalLatLng == null) {
      return <String, String>{
        q1Key: EncryptUtils.encode(answer1, encryptClient)!,
        q2Key: EncryptUtils.encode(answer2, encryptClient)!,
        q3Key: EncryptUtils.encode(answer3, encryptClient)!,
        q4Key: EncryptUtils.encode(answer4, encryptClient)!,
        q5Key: EncryptUtils.encode(answer5, encryptClient)!,
        q6Key: EncryptUtils.encode(answer6, encryptClient)!,
        q7Key: EncryptUtils.encode(answer7, encryptClient)!,
        deviceKey: EncryptUtils.encode(deviceInfo!, encryptClient)!,
        obTimeKey: EncryptUtils.encode(
            TimeUtils.getFormattedTimeYYYYmmDDHHmmSS(dateTime), encryptClient)!,
        latitudeKey: EncryptUtils.encode(
            Constants.defaultLatLng.latitude.toString(), encryptClient)!,
        longitudeKey: EncryptUtils.encode(
            Constants.defaultLatLng.longitude.toString(), encryptClient)!,
      };
    } else {
      return <String, String>{
        q1Key: EncryptUtils.encode(answer1, encryptClient)!,
        q2Key: EncryptUtils.encode(answer2, encryptClient)!,
        q3Key: EncryptUtils.encode(answer3, encryptClient)!,
        q4Key: EncryptUtils.encode(answer4, encryptClient)!,
        q5Key: EncryptUtils.encode(answer5, encryptClient)!,
        q6Key: EncryptUtils.encode(answer6, encryptClient)!,
        q7Key: EncryptUtils.encode(answer7, encryptClient)!,
        deviceKey: EncryptUtils.encode(deviceInfo!, encryptClient)!,
        obTimeKey: EncryptUtils.encode(
            TimeUtils.getFormattedTimeYYYYmmDDHHmmSS(dateTime), encryptClient)!,
        latitudeKey: EncryptUtils.encode(
            Global.globalLatLng!.latitude.toString(), encryptClient)!,
        longitudeKey: EncryptUtils.encode(
            Global.globalLatLng!.longitude.toString(), encryptClient)!,
      };
    }
  }

  /// get a map of formatted monitor information for further processing
  /// @param cgmList - a list data of cgm
  ///        mealList - a list data of meal
  ///        insList - a list data of insulin
  ///        dateTime - time of survey submitting
  /// @return surveyMap - K-V structure to make further process more convenient
  static Future<Map<String, String>> getFormattedMonitor(
      List<String> cgmList,
      List<String> mealList,
      List<String> insList,
      DateTime dateTime,
      EncryptClient encryptClient) async {
    String? deviceInfo = await PlatformDeviceId.getDeviceId;
    if ((deviceInfo == null || deviceInfo.trim() == "") && Platform.isLinux) {
      deviceInfo = DeviceInfoPlugin().linuxInfo.toString();
    }
    String cgmKey = EncryptUtils.encode(Constants.cgmKey, encryptClient)!;
    String mealKey = EncryptUtils.encode(Constants.mealKey, encryptClient)!;
    String insKey = EncryptUtils.encode(Constants.insKey, encryptClient)!;
    String deviceKey = EncryptUtils.encode(Constants.deviceKey, encryptClient)!;
    String obTimeKey = EncryptUtils.encode(Constants.obTimeKey, encryptClient)!;
    String latitudeKey =
    EncryptUtils.encode(Constants.latitudeKey, encryptClient)!;
    String longitudeKey =
    EncryptUtils.encode(Constants.longitudeKey, encryptClient)!;
    if (Global.globalLatLng == null) {
      return <String, String>{
        cgmKey: EncryptUtils.encode(jsonEncode(cgmList), encryptClient)!,
        mealKey: EncryptUtils.encode(jsonEncode(mealList), encryptClient)!,
        insKey: EncryptUtils.encode(jsonEncode(insList), encryptClient)!,
        deviceKey: EncryptUtils.encode(deviceInfo!, encryptClient)!,
        obTimeKey: EncryptUtils.encode(
            TimeUtils.getFormattedTimeYYYYmmDDHHmmSS(dateTime), encryptClient)!,
        latitudeKey: EncryptUtils.encode(
            Constants.defaultLatLng.latitude.toString(), encryptClient)!,
        longitudeKey: EncryptUtils.encode(
            Constants.defaultLatLng.longitude.toString(), encryptClient)!,
      };
    } else {
      return <String, String>{
        cgmKey: EncryptUtils.encode(jsonEncode(cgmList), encryptClient)!,
        mealKey: EncryptUtils.encode(jsonEncode(mealList), encryptClient)!,
        insKey: EncryptUtils.encode(jsonEncode(insList), encryptClient)!,
        deviceKey: EncryptUtils.encode(deviceInfo!, encryptClient)!,
        obTimeKey: EncryptUtils.encode(
            TimeUtils.getFormattedTimeYYYYmmDDHHmmSS(dateTime), encryptClient)!,
        latitudeKey: EncryptUtils.encode(
            Global.globalLatLng!.latitude.toString(), encryptClient)!,
        longitudeKey: EncryptUtils.encode(
            Global.globalLatLng!.longitude.toString(), encryptClient)!,
      };
    }
  }
}
