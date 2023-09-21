/// The widget for displaying PROFILE page
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

import 'package:flutter/material.dart';
import 'package:securedialog/model/chart_point.dart';
import 'package:securedialog/model/survey_day_info.dart';
import 'package:securedialog/ui/home_page/home_charts/DataTableWidget.dart';
import 'package:securedialog/utils/base_widget.dart';
import 'package:securedialog/utils/chart_utils.dart';
import 'package:securedialog/utils/time_utils.dart';

import '../../model/table_point.dart';
import '../../model/tooltip.dart';
import '../../service/home_page_service.dart';
import '../../utils/constants.dart';
import '../login_page/login_page.dart';
import 'home_charts/group_chart_widget.dart';
import 'home_charts/syncfusion_column_chart_widget.dart';
import 'home_charts/syncfusion_line_chart_widget.dart';

/// the view layer of profile widget in home page
class HomeProfile extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const HomeProfile(this.authData, {Key? key}) : super(key: key);

  @override
  State<HomeProfile> createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  final HomePageService homePageService = HomePageService();
  bool _showTable = false;

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
                  // request failed
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
                          "Server Error:${snapshot.error}",
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
                  List<String> timeList = [];
                  List<List<ToolTip>> strengthToolTipsList = [];
                  List<List<ToolTip>> fastingToolTipsList = [];
                  List<List<ToolTip>> postprandialToolTipsList = [];
                  List<List<ToolTip>> diastolicToolTipsList = [];
                  List<List<ToolTip>> weightToolTipsList = [];
                  List<List<ToolTip>> systolicToolTipsList = [];
                  List<List<ToolTip>> heartRateToolTipsList = [];
                  List<double> strengthList1 = [];
                  List<String> strengthTimeList1 = [];
                  List<double> fastingList1 = [];
                  List<String> fastingTimeList1 = [];
                  List<double> postprandialList1 = [];
                  List<String> postprandialTimeList1 = [];
                  List<double> diastolicList1 = [];
                  List<String> diastolicTimeList1 = [];
                  List<double> weightList1 = [];
                  List<String> weightTimeList1 = [];
                  List<double> systolicList1 = [];
                  List<String> systolicTimeList1 = [];
                  List<double> heartRateList1 = [];
                  List<String> heartRateTimeList1 = [];
                  List<String> timeList1 = [];
                  List<List<ToolTip>> strengthToolTipsList1 = [];
                  List<List<ToolTip>> fastingToolTipsList1 = [];
                  List<List<ToolTip>> postprandialToolTipsList1 = [];
                  List<List<ToolTip>> diastolicToolTipsList1 = [];
                  List<List<ToolTip>> weightToolTipsList1 = [];
                  List<List<ToolTip>> systolicToolTipsList1 = [];
                  List<List<ToolTip>> heartRateToolTipsList1 = [];
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
                    timeList.add(TimeUtils.reformatDate(charPoint.obTimeDay));
                    strengthToolTipsList.add(charPoint.otherStrength);
                    fastingToolTipsList.add(charPoint.otherFasting);
                    postprandialToolTipsList.add(charPoint.otherPostprandial);
                    diastolicToolTipsList.add(charPoint.otherDiastolic);
                    weightToolTipsList.add(charPoint.otherWeight);
                    systolicToolTipsList.add(charPoint.otherSystolic);
                    heartRateToolTipsList.add(charPoint.otherHeartRate);
                  }
                  List<TablePoint> tableList = ChartUtils.parseToTable(
                      surveyDayInfoList);
                  for (TablePoint tablePoint in tableList) {
                    strengthList1.add(tablePoint.strengthMax);
                    strengthTimeList1.add(tablePoint.strengthMaxTime);
                    fastingList1.add(tablePoint.fastingMax);
                    fastingTimeList1.add(tablePoint.fastingMaxTime);
                    postprandialList1.add(tablePoint.postprandialMax);
                    postprandialTimeList1.add(tablePoint.postprandialMaxTime);
                    diastolicList1.add(tablePoint.diastolicMax);
                    diastolicTimeList1.add(tablePoint.diastolicMaxTime);
                    weightList1.add(tablePoint.weightMax);
                    weightTimeList1.add(tablePoint.weightMaxTime);
                    systolicList1.add(tablePoint.systolicMax);
                    systolicTimeList1.add(tablePoint.systolicMaxTime);
                    heartRateList1.add(tablePoint.heartRateMax);
                    heartRateTimeList1.add(tablePoint.heartRateMaxTime);
                    timeList1.add(TimeUtils.reformatDate(tablePoint.obTimeDay));
                    strengthToolTipsList1.add(tablePoint.otherStrength);
                    fastingToolTipsList1.add(tablePoint.otherFasting);
                    postprandialToolTipsList1.add(tablePoint.otherPostprandial);
                    diastolicToolTipsList1.add(tablePoint.otherDiastolic);
                    weightToolTipsList1.add(tablePoint.otherWeight);
                    systolicToolTipsList1.add(tablePoint.otherSystolic);
                    heartRateToolTipsList1.add(tablePoint.otherHeartRate);
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
                      TextButton(
                        onPressed: (){
                          setState(() {
                            _showTable = !_showTable;
                          });
                        },
                        child: const Text(
                            "Show Table Data",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueAccent,
                            fontFamily: "KleeOne",
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      if (_showTable)...[
                        DataTableWidget(
                            timeList1,
                            strengthTimeList1,
                            strengthList1,
                            fastingList1,
                            fastingTimeList1,
                            postprandialList1,
                            postprandialTimeList1,
                            diastolicList1,
                            diastolicTimeList1,
                            weightList1,
                            weightTimeList1,
                            systolicList1,
                            systolicTimeList1,
                            heartRateList1,
                            heartRateTimeList1,
                            strengthToolTipsList1,
                            fastingToolTipsList1,
                            postprandialToolTipsList1,
                            diastolicToolTipsList1,
                            weightToolTipsList1,
                            systolicToolTipsList1,
                            heartRateToolTipsList1),
                        BaseWidget.getPadding(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  // Logic to export the table to a CSV file
                                },
                                child: Text("Export to CSV"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showTable = false;
                                });
                              },
                              child: Text("Close"),
                            ),
                          ],
                        ),
                      ],
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Lacking in Strength Check"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: SyncfusionColumnChartWidget(
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
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: SyncfusionLineChartWidget(
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
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: SyncfusionLineChartWidget(
                            postprandialList,
                            postprandialTimeList,
                            timeList,
                            Constants.postprandialMinY,
                            postprandialToolTipsList),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Systolic & Diastolic"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 150,
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
                      BaseWidget.getQuestionText("Weight"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: SyncfusionLineChartWidget(
                            weightList,
                            weightTimeList,
                            timeList,
                            Constants.weightMinY,
                            weightToolTipsList),
                      ),
                      BaseWidget.getPadding(15),
                      BaseWidget.getQuestionText("Heart Rate"),
                      BaseWidget.getPadding(5),
                      SizedBox(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: SyncfusionLineChartWidget(
                            heartRateList,
                            heartRateTimeList,
                            timeList,
                            Constants.heartRateMinY,
                            heartRateToolTipsList),
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
