/// The widget for displaying Data page
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
/// Authors: Ye Duan

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:securedialog/model/survey_day_info.dart';
import 'package:securedialog/ui/home_page/home_charts/data_table_widget.dart';
import 'package:securedialog/utils/base_widget.dart';
import 'package:securedialog/utils/chart_utils.dart';
import 'package:securedialog/utils/time_utils.dart';
import 'package:share/share.dart';

import '../../model/table_point.dart';
import '../../model/tooltip.dart';
import '../../service/home_page_service.dart';
import 'package:securedialog/constants/app.dart';
import 'package:csv/csv.dart';
import 'dart:io';

/// the view layer of profile widget in home page
class HomeData extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const HomeData(this.authData, {Key? key}) : super(key: key);

  @override
  State<HomeData> createState() => _HomeDataState();
}

class _HomeDataState extends State<HomeData> {
  final HomePageService homePageService = HomePageService();

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

  Future<void> exportToCsv() async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "Data",
      "Time",
      "Systolic",
      "Diastolic",
      "Heart Rate",
      "Weight",
      "Strength Level",
      "Fasting Blood Glucose",
      "Postprandial Blood Glucose",
    ]);

    // Data
    for (int rowIndex = 0; rowIndex < timeList1.length; rowIndex++) {
      if (strengthTimeList1[rowIndex] != 'none') {
        // Main data row
        List<dynamic> row = [
          timeList1[rowIndex],
          strengthTimeList1[rowIndex],
          systolicList1[rowIndex],
          diastolicList1[rowIndex],
          heartRateList1[rowIndex],
          weightList1[rowIndex],
          mapValueToText(strengthList1[rowIndex]),
          fastingList1[rowIndex],
          postprandialList1[rowIndex],
        ];

        rows.add(row);

        // Tooltip rows for strength
        for (int i = 0; i < strengthToolTipsList1[rowIndex].length; i++) {
          List<dynamic> row1 = [
            timeList1[rowIndex],
            TimeUtils.convertHHmmToClock(
                strengthToolTipsList1[rowIndex][i].time),
            setNull(systolicToolTipsList1[rowIndex][i].val),
            setNull(diastolicToolTipsList1[rowIndex][i].val),
            setNull(heartRateToolTipsList1[rowIndex][i].val),
            setNull(weightToolTipsList1[rowIndex][i].val),
            mapValueToText(strengthToolTipsList1[rowIndex][i].val),
            setNull(fastingToolTipsList1[rowIndex][i].val),
            setNull(postprandialToolTipsList1[rowIndex][i].val),
          ];
          rows.add(row1);
        }
      }
    }

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);

    // Save CSV string to a file (or share it)
    final directory = await getExternalStorageDirectory();
    final path = directory!.path;
    final file = File("$path/export.csv");
    await file.writeAsString(csv);

    // Use the share plugin to share the file
    Share.shareFiles(['$path/export.csv'], text: 'My CSV data');
  }

  Future<void> importFromCsv() async {
    try {
      // Let the user pick a CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        final csvString = await file.readAsString();
        List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

        // Skip the header row and append data
        for (int i = 1; i < rows.length; i++) {
          List<dynamic> row = rows[i];
          if (row.length >= 9) {
            String dateString = "${row[0]} ${row[1]}"; // Combines date and time
            dateString = dateString.replaceAll('/', '-'); // Replace '/' with '-'
            List<String> parts = dateString.split(" ");
            if (parts.length == 2) {
              List<String> timeParts = parts[1].split(":");
              if (timeParts.length == 2) {
                String hour = timeParts[0].padLeft(2, '0'); // Pad hour with 0 if it's one digit
                String minute = timeParts[1].padLeft(2, '0'); // Pad minute with 0 if it's one digit
                dateString = "${parts[0]} $hour:$minute"; // Reconstruct the date string
              }
            }
            DateTime? dateTime = DateTime.tryParse(dateString);
            if (dateTime == null) {
              // Handle the case where the date-time is invalid
              debugPrint("Invalid date-time format in CSV: ${row[0]} ${row[1]}");
              continue; // Skip this row or handle appropriately
            }
            await homePageService.saveSurveyInfo(
                row[6].toString(),
                row[7].toString(),
                row[8].toString(),
                row[2].toString(),
                row[3].toString(),
                row[5].toString(),
                row[4].toString(),
                widget.authData,
                dateTime
            );
          }
        }
        setState(() {
          // Update the UI with the new data
        });
      } else {
        // User canceled the picker
      }
    } catch (e) {
      // Handle any exceptions
      debugPrint("Error while importing CSV: $e");
    }
  }

  void onDelete(String date, String time) async {
    // Combine date and time to form the criteria or file name
    String criteria = "$date$time";
    // Call the method to delete the file from the POD
    await homePageService.deleteFileMatchingCriteria(widget.authData, criteria);
  }

  Future<void> refreshData() async {
    try {
      // Fetch the new survey data
      List<SurveyDayInfo>? newSurveyDayInfoList = await homePageService.getSurveyDayInfoList(
          Constants.barNumber, widget.authData);

      if (newSurveyDayInfoList != null) {
        // Parse the new data
        List<TablePoint> newTableList = ChartUtils.parseToTable(newSurveyDayInfoList);

        // Clear the existing data lists
        clearDataLists();

        // Update the data lists with the new data
        for (TablePoint tablePoint in newTableList) {
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
          timeList1.add(
              TimeUtils.reformatDateForTable(tablePoint.obTimeDay));
          strengthToolTipsList1.add(tablePoint.otherStrength);
          fastingToolTipsList1.add(tablePoint.otherFasting);
          postprandialToolTipsList1.add(tablePoint.otherPostprandial);
          diastolicToolTipsList1.add(tablePoint.otherDiastolic);
          weightToolTipsList1.add(tablePoint.otherWeight);
          systolicToolTipsList1.add(tablePoint.otherSystolic);
          heartRateToolTipsList1.add(tablePoint.otherHeartRate);
        }

        // Update the UI with the new data
        setState(() {});
      }
    } catch (e) {
      // Handle any errors
      debugPrint("Error while refreshing data: $e");
    }
  }

  void clearDataLists() {
    strengthList1.clear();
    strengthTimeList1.clear();
    fastingList1.clear();
    fastingTimeList1.clear();
    postprandialList1.clear();
    postprandialTimeList1.clear();
    diastolicList1.clear();
    diastolicTimeList1.clear();
    weightList1.clear();
    weightTimeList1.clear();
    systolicList1.clear();
    systolicTimeList1.clear();
    heartRateList1.clear();
    heartRateTimeList1.clear();
    timeList1.clear();
    strengthToolTipsList1.clear();
    fastingToolTipsList1.clear();
    postprandialToolTipsList1.clear();
    diastolicToolTipsList1.clear();
    weightToolTipsList1.clear();
    systolicToolTipsList1.clear();
    heartRateToolTipsList1.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: SafeArea(
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
                          "Historical data in your Pod",
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
                  ],
                );
              } else {
                // request success
                strengthList1 = [];
                strengthTimeList1 = [];
                fastingList1 = [];
                fastingTimeList1 = [];
                postprandialList1 = [];
                postprandialTimeList1 = [];
                diastolicList1 = [];
                diastolicTimeList1 = [];
                weightList1 = [];
                weightTimeList1 = [];
                systolicList1 = [];
                systolicTimeList1 = [];
                heartRateList1 = [];
                heartRateTimeList1 = [];
                timeList1 = [];
                strengthToolTipsList1 = [];
                fastingToolTipsList1 = [];
                postprandialToolTipsList1 = [];
                diastolicToolTipsList1 = [];
                weightToolTipsList1 = [];
                systolicToolTipsList1 = [];
                heartRateToolTipsList1 = [];
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
                            "Historical data in your Pod",
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
                    ],
                  );
                }
                List<TablePoint> tableList =
                    ChartUtils.parseToTable(surveyDayInfoList);
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
                  timeList1.add(
                      TimeUtils.reformatDateForTable(tablePoint.obTimeDay));
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
                          "Historical data in your Pod",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: "KleeOne",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    BaseWidget.getPadding(15),
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
                        heartRateToolTipsList1,
                        onDelete),
                    BaseWidget.getPadding(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: exportToCsv,
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.teal[400]),
                          ),
                          child: const Text("Export to CSV"),
                        ),
                        const SizedBox(width: 18),
                        ElevatedButton(
                          onPressed: importFromCsv,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.teal[400]),
                          ),
                          child: const Text("Import from CSV"),
                        ),
                        const SizedBox(width: 18),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          color: Colors.teal[400],
                          onPressed: refreshData,
                        ),
                      ],
                    ),
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
    );
  }

  String mapValueToText(double value) {
    switch (value.toInt()) {
      case -1:
        return 'Null';
      case 2:
        return 'No';
      case 4:
        return 'Mild';
      case 6:
        return 'Moderate';
      case 8:
        return 'Severe';
      default:
        return value.toString(); // default case, you can adjust as needed
    }
  }

  String setNull(double value) {
    if (value == -1.0) {
      return 'Null';
    } else {
      return value.toString();
    }
  }
}
