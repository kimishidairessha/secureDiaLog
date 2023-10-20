/// A widget for displaying the PROFILE page.
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

// 20230930 gjw TODOD
//
// SPLIT OUT VARIOUS WIDGETS INTO OWN CLASSES TO REDUCE THIS FILE SIZE AND FOR
// THE CODE TO BE MORE READABLE.
//
// REVIEW AND CLEANUP THE LAYOUT AND COMMENTS AND CHCEK THE DOCS GENERATION
// PRODUCES USEFUL DOCUMENTATION.

import 'package:flutter/material.dart';

import 'package:securedialog/model/chart_point.dart';
import 'package:securedialog/model/survey_day_info.dart';
import 'package:securedialog/model/tooltip.dart';
import 'package:securedialog/service/home_page_service.dart';
import 'package:securedialog/ui/login_page/login_page.dart';
import 'package:securedialog/utils/base_widget.dart';
import 'package:securedialog/utils/chart_utils.dart';
import 'package:securedialog/utils/constants.dart';
import 'package:securedialog/utils/time_utils.dart';

// 20230930 gjw TODO CAN THESE BE REPLACED WITH THE PACKAGE:SECUREDIALOG USAGE?
// IS THERE ANY REASON NOT TO DO THAT?

import 'home_charts/group_chart_widget.dart';
import 'home_charts/column_chart_widget.dart';
import 'home_charts/line_chart_widget.dart';

/// A view layer for the profile widget in the home page.

class HomeProfile extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const HomeProfile(this.authData, {Key? key}) : super(key: key);

  @override
  State<HomeProfile> createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  final HomePageService homePageService = HomePageService();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<SurveyDayInfo>?>(
            future: homePageService.getSurveyDayInfoList(
                Constants.barNumber, widget.authData),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // request is complete
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  // Request failed.

                  return Column(
                    children: <Widget>[
                      BaseWidget.getPadding(15.0),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: const Text(
                            "Welcome to your POD",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      BaseWidget.getPadding(25),
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                          "Server Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: "KleeOne",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      BaseWidget.getPadding(25),
                      BaseWidget.getElevatedButton(() async {
                        bool? isLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return BaseWidget.getConfirmationDialog(
                                  context,
                                  "Message",
                                  "Are you sure to logout?",
                                  "Emm, not yet",
                                  "Goodbye");
                            });
                        if (isLogout == null || !isLogout || !mounted) {
                          return;
                        }
                        homePageService.logout(widget.authData!["logoutUrl"]);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) {
                          return const LoginPage();
                        }));
                      }, "Logout", MediaQuery.of(context).size.width / 1.25,
                          50),
                    ],
                  );
                } else {
                  // request success
                  List<double> strengthList = [];
                  List<String> strengthTimeList = [];
                  List<double> fastingList = [];
                  List<String> fastingTimeList = [];
                  List<double> postprandialList = [];
                  List<String> postprandialTimeList = [];
                  List<double> diastolicList = [];
                  List<String> diastolicTimeList = [];
                  List<double> weightList = [];
                  List<String> weightTimeList = [];
                  List<double> systolicList = [];
                  List<String> systolicTimeList = [];
                  List<double> heartRateList = [];
                  List<String> heartRateTimeList = [];
                  List<String> obTimeList = [];
                  List<String> timeList = [];
                  List<List<ToolTip>> strengthToolTipsList = [];
                  List<List<ToolTip>> fastingToolTipsList = [];
                  List<List<ToolTip>> postprandialToolTipsList = [];
                  List<List<ToolTip>> diastolicToolTipsList = [];
                  List<List<ToolTip>> weightToolTipsList = [];
                  List<List<ToolTip>> systolicToolTipsList = [];
                  List<List<ToolTip>> heartRateToolTipsList = [];
                  List<SurveyDayInfo>? surveyDayInfoList = snapshot.data;
                  if (surveyDayInfoList == null) {
                    return Column(
                      children: <Widget>[
                        BaseWidget.getPadding(15.0),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: const Text(
                              "Welcome to your POD",
                              style: TextStyle(
                                fontSize: 30,
                                fontFamily: "KleeOne",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        BaseWidget.getPadding(25),
                        Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: const Text(
                            """Ops, something wrong when fetching your reports' data (::>_<::)\nThe data analysis function will only start working after reporting at least one Q&A survey""",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        BaseWidget.getPadding(25),
                        BaseWidget.getElevatedButton(() async {
                          bool? isLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return BaseWidget.getConfirmationDialog(
                                    context,
                                    "Message",
                                    "Are you sure to logout?",
                                    "Emm, not yet",
                                    "Goodbye");
                              });
                          if (isLogout == null || !isLogout || !mounted) {
                            return;
                          }
                          homePageService.logout(widget.authData!["logoutUrl"]);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) {
                            return const LoginPage();
                          }));
                        }, "Logout", MediaQuery.of(context).size.width / 1.25,
                            50),
                      ],
                    );
                  }
                  List<ChartPoint> chartPointList = ChartUtils.parseToChart(
                      surveyDayInfoList, Constants.barNumber);
                  for (ChartPoint charPoint in chartPointList) {
                    strengthList.add(charPoint.strengthMax);
                    strengthTimeList.add(charPoint.strengthMaxTime);
                    fastingList.add(charPoint.fastingMax);
                    fastingTimeList.add(charPoint.fastingMaxTime);
                    postprandialList.add(charPoint.postprandialMax);
                    postprandialTimeList.add(charPoint.postprandialMaxTime);
                    diastolicList.add(charPoint.diastolicMax);
                    diastolicTimeList.add(charPoint.diastolicMaxTime);
                    weightList.add(charPoint.weightMax);
                    weightTimeList.add(charPoint.weightMaxTime);
                    systolicList.add(charPoint.systolicMax);
                    systolicTimeList.add(charPoint.systolicMaxTime);
                    heartRateList.add(charPoint.heartRateMax);
                    heartRateTimeList.add(charPoint.heartRateMaxTime);
                    obTimeList.add(
                        TimeUtils.convertDateToWeekDay(charPoint.obTimeDay));
                    timeList.add(TimeUtils.reformatDate(charPoint.obTimeDay));
                    strengthToolTipsList.add(charPoint.otherStrength);
                    fastingToolTipsList.add(charPoint.otherFasting);
                    postprandialToolTipsList.add(charPoint.otherPostprandial);
                    diastolicToolTipsList.add(charPoint.otherDiastolic);
                    weightToolTipsList.add(charPoint.otherWeight);
                    systolicToolTipsList.add(charPoint.otherSystolic);
                    heartRateToolTipsList.add(charPoint.otherHeartRate);
                  }
                  return Column(
                    children: <Widget>[
                      BaseWidget.getPadding(15.0),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: const Text(
                            "Welcome to your POD",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Systolic & Diastolic"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 320,
                        width: MediaQuery.of(context).size.width,
                        child: GroupChartWidget(
                            systolicList,
                            diastolicList,
                            systolicTimeList,
                            timeList,
                            Constants.systolicMinY,
                            systolicToolTipsList,
                            diastolicToolTipsList),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Heart Rate"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: LineChartWidget(
                            heartRateList,
                            heartRateTimeList,
                            timeList,
                            Constants.heartRateMinY,
                            heartRateToolTipsList),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Weight"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: LineChartWidget(weightList, weightTimeList,
                            timeList, Constants.weightMinY, weightToolTipsList),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Lacking in Strength Check"),
                      SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: ColumnChartWidget(
                            strengthList,
                            strengthTimeList,
                            timeList,
                            Constants.optionMaxY,
                            strengthToolTipsList),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Fasting Blood Glucose"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: LineChartWidget(
                            fastingList,
                            fastingTimeList,
                            timeList,
                            Constants.fastingMinY,
                            fastingToolTipsList),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Postprandial Blood Glucose"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: LineChartWidget(
                            postprandialList,
                            postprandialTimeList,
                            timeList,
                            Constants.postprandialMinY,
                            postprandialToolTipsList),
                      ),
                      BaseWidget.getPadding(30.0),
                    ],
                  );
                }
              } else {
                // requesting，display 'loading'
                return Container(
                  height: MediaQuery.of(context).size.height - 150,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
