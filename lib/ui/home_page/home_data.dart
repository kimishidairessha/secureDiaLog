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

// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securedialog/model/survey_day_info.dart';
import 'package:securedialog/ui/home_page/home_charts/data_table_widget.dart';
import 'package:securedialog/utils/base_widget.dart';
import 'package:securedialog/utils/chart_utils.dart';
import 'package:securedialog/utils/data_refresher.dart';
import 'package:securedialog/utils/time_utils.dart';
import 'package:securedialog/model/table_point.dart';
import 'package:securedialog/model/tooltip.dart';
import 'package:securedialog/service/home_page_service.dart';
import 'package:securedialog/constants/app.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:securedialog/utils/file_saver_mobile.dart'
    if (dart.library.html) 'package:securedialog/utils/file_saver_web.dart'
    as file_saver;

/// the view layer of profile widget in home page
class HomeData extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const HomeData(this.authData, {Key? key}) : super(key: key);

  @override
  State<HomeData> createState() => _HomeDataState();
}

class _HomeDataState extends State<HomeData> {
  final HomePageService homePageService = HomePageService();

  List<String> timeList1 = [];
  List<List<ToolTip>> strengthToolTipsList1 = [];
  List<List<ToolTip>> fastingToolTipsList1 = [];
  List<List<ToolTip>> postprandialToolTipsList1 = [];
  List<List<ToolTip>> diastolicToolTipsList1 = [];
  List<List<ToolTip>> weightToolTipsList1 = [];
  List<List<ToolTip>> systolicToolTipsList1 = [];
  List<List<ToolTip>> heartRateToolTipsList1 = [];

  Future<void> exportToCsv(String fileName) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "Date",
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
      if (timeList1[rowIndex] != 'none') {
        // Tooltip rows for strength
        for (int i = 0; i < strengthToolTipsList1[rowIndex].length; i++) {
          List<dynamic> row = [
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
          rows.add(row);
        }
      }
    }

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);

    if (fileName.toLowerCase().endsWith('.csv')) {
      fileName = fileName.substring(0, fileName.length - 4);
    }

    file_saver.saveAndShareCsv(csv, fileName);
  }

  Future<void> promptFileNameAndExport() async {
    TextEditingController fileNameController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Filename'),
          content: TextField(
            controller: fileNameController,
            decoration:
                InputDecoration(
                    hintText:
                    'dialog_${TimeUtils.getFormattedTimeYYYYmmDD(DateTime.now())}'
                ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Export'),
              onPressed: () {
                Navigator.of(context).pop();
                exportToCsv(fileNameController.text.isNotEmpty
                    ? fileNameController.text :
                'dialog_${TimeUtils.getFormattedTimeYYYYmmDD(DateTime.now())}');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> importFromCsv() async {
    try {
      // Let the user pick a CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null) {
        PlatformFile pickedFile = result.files.first;

        String csvString;

        // Check if running on the web
        if (kIsWeb) {
          // Use the 'bytes' property for web
          final bytes = pickedFile.bytes;
          csvString = String.fromCharCodes(bytes!);
        } else {
          // Use the 'path' property for other platforms
          File file = File(pickedFile.path!);
          csvString = await file.readAsString();
        }
        // File file = File(result.files.single.path!);
        //
        // final csvString = await file.readAsString();

        List<List<dynamic>> rows =
            const CsvToListConverter().convert(csvString);

        // Skip the header row and append data
        for (int i = 1; i < rows.length; i++) {
          List<dynamic> row = rows[i];
          if (row.length >= 9) {
            String dateString = "${row[0]} ${row[1]}"; // Combines date and time
            dateString =
                dateString.replaceAll('/', '-'); // Replace '/' with '-'
            List<String> parts = dateString.split(" ");
            if (parts.length == 2) {
              List<String> dateParts = parts[0].split("-");
              List<String> timeParts = parts[1].split(":");
              if(dateParts.length == 3){
                String year = dateParts[0];
                String month = dateParts[1].padLeft(2, '0');
                String day = dateParts[2].padLeft(2, '0');
                parts[0] = "$year-$month-$day";
              }
              if (timeParts.length == 2) {
                String hour = timeParts[0]
                    .padLeft(2, '0'); // Pad hour with 0 if it's one digit
                String minute = timeParts[1]
                    .padLeft(2, '0'); // Pad minute with 0 if it's one digit
                dateString =
                    "${parts[0]} $hour:$minute"; // Reconstruct the date string
              }
            }
            DateTime? dateTime = DateTime.tryParse(dateString);
            if (dateTime == null) {
              // Handle the case where the date-time is invalid
              debugPrint(
                  "Invalid date-time format in CSV: ${row[0]} ${row[1]}");
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
                dateTime);
          }
        }
        setState(() {
          // Update the UI with the new data
        });
        Provider.of<DataRefresher>(context, listen: false).refreshData();
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
    Provider.of<DataRefresher>(context, listen: false).refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: SingleChildScrollView(
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
                            onPressed: promptFileNameAndExport,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.teal[400]),
                            ),
                            child: const Text("Export to CSV",
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 18),
                          ElevatedButton(
                            onPressed: importFromCsv,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.teal[400]),
                            ),
                            child: const Text("Import from CSV",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      BaseWidget.getPadding(70),
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
