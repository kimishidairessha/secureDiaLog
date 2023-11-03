/// The widget for displaying a table chart
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

import 'package:flutter/material.dart';
import 'package:securedialog/constants/app.dart';
import 'package:securedialog/model/tooltip.dart';
import 'package:securedialog/utils/time_utils.dart';

class DataTableWidget extends StatefulWidget {
  final List<String> timeList;
  final List<String> strengthTimeList;
  final List<double> strengthList;
  final List<double> fastingList;
  final List<String> fastingTimeList;
  final List<double> postprandialList;
  final List<String> postprandialTimeList;
  final List<double> diastolicList;
  final List<String> diastolicTimeList;
  final List<double> weightList;
  final List<String> weightTimeList;
  final List<double> systolicList;
  final List<String> systolicTimeList;
  final List<double> heartRateList;
  final List<String> heartRateTimeList;
  final List<List<ToolTip>> strengthToolTipsList;
  final List<List<ToolTip>> fastingToolTipsList;
  final List<List<ToolTip>> postprandialToolTipsList;
  final List<List<ToolTip>> diastolicToolTipsList;
  final List<List<ToolTip>> weightToolTipsList;
  final List<List<ToolTip>> systolicToolTipsList;
  final List<List<ToolTip>> heartRateToolTipsList;

  const DataTableWidget(
      this.timeList,
      this.strengthTimeList,
      this.strengthList,
      this.fastingList,
      this.fastingTimeList,
      this.postprandialList,
      this.postprandialTimeList,
      this.diastolicList,
      this.diastolicTimeList,
      this.weightList,
      this.weightTimeList,
      this.systolicList,
      this.systolicTimeList,
      this.heartRateList,
      this.heartRateTimeList,
      this.strengthToolTipsList,
      this.fastingToolTipsList,
      this.postprandialToolTipsList,
      this.diastolicToolTipsList,
      this.weightToolTipsList,
      this.systolicToolTipsList,
      this.heartRateToolTipsList,
      {Key? key})
      : super(key: key);

  @override
  State<DataTableWidget> createState() => _DataTableWidget();
}

class _DataTableWidget extends State<DataTableWidget> {
  final ScrollController controller = ScrollController();
  final ScrollController controller2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller2,
      // isAlwaysShown: true,
      child: SingleChildScrollView(
        controller: controller2,
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Container(
              color: Constants.tableColor,
              child: const DefaultTextStyle(
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 42.0, vertical: 15.0),
                      child: Text('Data'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15.0),
                      child: Text('Time'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 15.0),
                      child: Text('Systolic'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 15.0),
                      child: Text('Diastolic'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 15.0),
                      child: Text('Heart Rate'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 15.0),
                      child: Text('Weight'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 15.0),
                      child: Text('Strength Level'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 26.0, vertical: 15.0),
                      child: Text('Fasting Blood Glucose'),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 26.0, right: 18.0, top: 15.0, bottom: 15.0),
                      child: Text('Postprandial Blood Glucose'),
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable rows
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.48), // adjust as needed
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Container(
                    color: Constants.tableColor,
                    child: DataTable(
                      headingRowHeight: 0,
                      columns: const [
                        DataColumn(label: Text('Data')),
                        DataColumn(label: Text('Time')),
                        DataColumn(label: Text('Systolic')),
                        DataColumn(label: Text('Diastolic')),
                        DataColumn(label: Text('Heart Rate')),
                        DataColumn(label: Text('Weight')),
                        DataColumn(label: Text('Strength Level')),
                        DataColumn(label: Text('Fasting Blood Glucose')),
                        DataColumn(label: Text('Postprandial Blood Glucose')),
                      ],
                      rows: createRows(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> createRows() {
    List<DataRow> allRows = [];
    for (int rowIndex = 0; rowIndex < widget.timeList.length; rowIndex++) {
      if (widget.strengthTimeList[rowIndex] != 'none') {
        // Main data row
        allRows.add(DataRow(cells: [
          DataCell(Text(widget.timeList[rowIndex])),
          DataCell(Text(widget.strengthTimeList[rowIndex])),
          DataCell(Text('${widget.systolicList[rowIndex]}')),
          DataCell(Text('${widget.diastolicList[rowIndex]}')),
          DataCell(Text('${widget.heartRateList[rowIndex]}')),
          DataCell(Text('${widget.weightList[rowIndex]}')),
          DataCell(Text(mapValueToText(widget.strengthList[rowIndex]))),
          DataCell(Text('${widget.fastingList[rowIndex]}')),
          DataCell(Text('${widget.postprandialList[rowIndex]}')),
        ]));

        // Tooltip rows for strength
        for (int i = 0; i < widget.strengthToolTipsList[rowIndex].length; i++) {
          allRows.add(DataRow(cells: [
            DataCell(
                Text(widget.timeList[rowIndex])), // Date empty for tooltip rows
            DataCell(Text(TimeUtils.convertHHmmToClock(widget
                .strengthToolTipsList[rowIndex][i].time))), // Tooltip time
            DataCell(
                Text(setNull(widget.systolicToolTipsList[rowIndex][i].val))),
            DataCell(
                Text(setNull(widget.diastolicToolTipsList[rowIndex][i].val))),
            DataCell(
                Text(setNull(widget.heartRateToolTipsList[rowIndex][i].val))),
            DataCell(Text(setNull(widget.weightToolTipsList[rowIndex][i].val))),
            DataCell(Text(mapValueToText(widget
                .strengthToolTipsList[rowIndex][i].val))), // Tooltip value
            DataCell(
                Text(setNull(widget.fastingToolTipsList[rowIndex][i].val))),
            DataCell(Text(
                setNull(widget.postprandialToolTipsList[rowIndex][i].val))),
          ]));
        }
      }
    }
    return allRows;
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
