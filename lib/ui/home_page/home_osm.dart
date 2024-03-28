/// A widget to display the monitor page.
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

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:securedialog/constants/app.dart';
import 'package:securedialog/service/home_page_service.dart';
import 'package:securedialog/utils/base_widget.dart';

class HomeOSM extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const HomeOSM(this.authData, {Key? key}) : super(key: key);

  @override
  State<HomeOSM> createState() => _HomeOSMState();
}

class _HomeOSMState extends State<HomeOSM> {
  final HomePageService homePageService = HomePageService();

  @override
  void initState() {
    super.initState();
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

        if (kIsWeb) {
          // Web platform uses bytes
          final bytes = pickedFile.bytes;
          csvString = String.fromCharCodes(bytes!);
        } else {
          // Mobile and desktop platforms use file paths
          File file = File(pickedFile.path!);
          csvString = await file.readAsString();
        }

        List<List<dynamic>> rows =
        const CsvToListConverter().convert(csvString);

        List<String> cgmList = [];
        List<String> mealList = [];
        List<String> insList = [];
        // Process and collect data for each row
        for (List<dynamic> row in rows.skip(1)) {
          cgmList.add(row[0].toString());
          mealList.add(row[1].toString());
          insList.add(row[2].toString());
        }

        // Save the data to pod
        DateTime currentDate = DateTime.now();
        await homePageService.saveMonitorInfo(
            cgmList,
            mealList,
            insList,
            widget.authData,
            currentDate);

        setState(() {
          // Update the UI with the new data
        });
      }
    } catch (e) {
      debugPrint("Error while importing CSV: $e");
    }
  }

  LineChartData _buildChartData(
      List<dynamic> data, Color color, String leftTitle, String bottomTitle) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), double.parse(data[i].toString())));
    }

    return LineChartData(
      minY: 0,
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        show: true,
        // Configuring bottom titles (X-axis)
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50, // Space for the titles
            getTitlesWidget: (double value, TitleMeta meta) {
              List<String> times = ["00:00", "03:00", "06:00", "09:00", "12:00", "15:00", "18:00", "21:00", "24:00"];
              double interval = data.length / (times.length - 1); // Calculate the interval based on the number of labels

              int index = (value / interval).round(); // Find the nearest index based on the current value
              if (index >= 0 && index < times.length) {
                return Text(times[index]);
              }
              return Text('');
            },
          ),
        ),
        // Configuring left titles (Y-axis)
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Space for the titles, adjust as needed
            interval: 1, // Keep as 1 to check each value
            getTitlesWidget: (double value, TitleMeta meta) {
              // Display label only for every 50 units, adjust as needed
              if (value % 50 == 0) {
                return Text('${value.toInt()}', style: TextStyle(color: Colors.black, fontSize: 10),);
              }
              return Text('');
            },
          ),
        ),
        // Optionally hide top and right titles
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          dotData: FlDotData(show: false),
          barWidth: 4,
          color: color,
        ),
      ],
    );
  }

  LineChartData _buildInsChartData(
      List<dynamic> data, Color color, String leftTitle, String bottomTitle) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), double.parse(data[i].toString())));
    }

    return LineChartData(
      minY: 0,
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        show: true,
        // Configuring bottom titles (X-axis)
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50, // Space for the titles
            getTitlesWidget: (double value, TitleMeta meta) {
              List<String> times = ["00:00", "03:00", "06:00", "09:00", "12:00", "15:00", "18:00", "21:00", "24:00"];
              double interval = data.length / (times.length - 1); // Calculate the interval based on the number of labels

              int index = (value / interval).round(); // Find the nearest index based on the current value
              if (index >= 0 && index < times.length) {
                return Text(times[index]);
              }
              return Text('');
            },
          ),
        ),
        // Configuring left titles (Y-axis)
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              String formattedValue = value.toStringAsFixed(2);
              return Padding(
                padding: const EdgeInsets.only(right: 5.0), // Adjust padding as needed
                child: Text(formattedValue, style: TextStyle(color: Colors.black, fontSize: 10)),
              );
            },
            reservedSize: 30, // Adjust as needed for the formatted text
          ),
        ),
        // Optionally hide top and right titles
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          dotData: FlDotData(show: false),
          barWidth: 4,
          color: color,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: SingleChildScrollView(
        child: SafeArea(
          child: FutureBuilder<Map<String, List<dynamic>>>(
            future: homePageService.getMonitorInfoList(
                widget.authData),
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
                            "Monitor data in your Pod",
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
                  Map<String, List<dynamic>> monitorInfoList = snapshot.data;
                  List<dynamic> cgmData = monitorInfoList[Constants.cgmKey] ?? [];
                  List<dynamic> insData = monitorInfoList[Constants.insKey] ?? [];

                  return Column(
                    children: <Widget>[
                      BaseWidget.getPadding(15.0),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: const Text(
                            "Monitor data in your Pod",
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      BaseWidget.getPadding(15),
                      ElevatedButton(
                        onPressed: importFromCsv,
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.teal[400]),
                        ),
                        child: const Text("Import from CSV",
                            style: TextStyle(color: Colors.white)),
                      ),
                      BaseWidget.getPadding(15),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: const Text(
                            "Glucose data [mg/dL]",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      BaseWidget.getPadding(10),
                      // CGM Chart
                      SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LineChart(
                              _buildChartData(
                                  cgmData,
                                  Colors.blue,
                                  "CGM",
                                  "Time")),
                        ),
                      ),
                      BaseWidget.getPadding(15),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: const Text(
                            "Insulin data [U/min]",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "KleeOne",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      BaseWidget.getPadding(10),
                      // INS Chart
                      SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LineChart(
                              _buildInsChartData(
                                  insData,
                                  Colors.red,
                                  "INS",
                                  "Time")),
                        ),
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

}
