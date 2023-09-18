/// The widget for displaying a grouped chart
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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:securedialog/extensions/color_extensions.dart';

import '../../../model/tooltip.dart';
import '../../../utils/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../utils/time_utils.dart';

class GroupChartWidget extends StatefulWidget {
  final List<double> yList;
  final List<double> yList2;
  final List<String> timeList;
  final List<String> xList;
  final double minY;
  final List<List<ToolTip>> toolTipsList;
  final List<List<ToolTip>> toolTipsList2;

  const GroupChartWidget(this.yList, this.yList2, this.timeList, this.xList,
      this.minY, this.toolTipsList, this.toolTipsList2,
      {Key? key})
      : super(key: key);

  @override
  State<GroupChartWidget> createState() => _GroupChartWidgetState();
}

class _GroupChartWidgetState extends State<GroupChartWidget> {
  late List<BarChartGroupData> rawBarGroups;
  late ScrollController scrollController;
  late List<BarChartGroupData> visibleBarGroups;

  int visibleLength = 7;

  Widget bottomTitleWidget(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.teal,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text = Text('');
    for (int i = 0; i < widget.xList.length; i++) {
      if (value.toInt() == i) {
        text = Text(
          widget.xList[i],
          style: style,
        );
      }
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }


  @override
  void initState() {
    super.initState();
    // Initialize your data here...
    rawBarGroups = [];
    for (int i = 0; i < widget.yList.length; i++) {
      rawBarGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              fromY: widget.yList2[i],
              toY: widget.yList[i],
              color: Colors.blue,
            ),
          ],
          showingTooltipIndicators: [],
        ),
      );
    }
    // Create the scroll controller and add a listener to it
    scrollController = ScrollController(initialScrollOffset: (rawBarGroups.length - visibleLength) * 15.0,)
      ..addListener(() {
        updateVisibleData();
      });

    int initialIndex = (rawBarGroups.length > visibleLength) ? rawBarGroups.length - visibleLength : 0;
    visibleBarGroups = rawBarGroups.sublist(initialIndex, rawBarGroups.length);
  }

  int firstVisibleDataIndex = 8;

  void updateVisibleData() {
    print("updateVisibleData called");
    int calculatedIndex = (scrollController.offset / 15).floor();
    int maxFirstIndex = rawBarGroups.length - visibleLength;

    // Constrain firstVisibleDataIndex within valid bounds
    firstVisibleDataIndex = calculatedIndex.clamp(0, maxFirstIndex);
    int lastVisibleDataIndex = firstVisibleDataIndex + visibleLength;

    if (firstVisibleDataIndex >= 0 && lastVisibleDataIndex <= rawBarGroups.length) {
      setState(() {
        visibleBarGroups = rawBarGroups.sublist(
            firstVisibleDataIndex, lastVisibleDataIndex);
      });
    }
    print("First: $firstVisibleDataIndex, Last: $lastVisibleDataIndex");
  }


  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();

    if (chartData.isEmpty) {
      // No data to display
      return const Center(
        child: Text('No data available.'),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal, // makes it horizontally scrollable
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 38 * rawBarGroups.length.toDouble(), // dynamic minWidth
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 10,
            ),
            child: BarChart(
              BarChartData(
                maxY: 220,
                barGroups: visibleBarGroups,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueAccent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      print("Group index: $groupIndex, Rod index: $rodIndex");
                      int adjustedGroupIndex = groupIndex + firstVisibleDataIndex;
                      print(adjustedGroupIndex);
                      String time = widget.timeList[adjustedGroupIndex];
                      String systolic = widget.yList[adjustedGroupIndex].toString();
                      String diastolic = widget.yList2[adjustedGroupIndex].toString();

                      String tooltipText =
                          "$time\nSystolic: $systolic\nDiastolic: $diastolic";

                      if (widget.toolTipsList.isNotEmpty &&
                          widget.toolTipsList[adjustedGroupIndex].isNotEmpty) {
                        tooltipText += "\n--------------\nSystolic updating:";
                        for (ToolTip toolTip in widget.toolTipsList[adjustedGroupIndex]) {
                          String additionalText =
                              "\n${toolTip.time} - ${toolTip.val.toString()}";
                          tooltipText += additionalText;
                        }
                      }

                      if (widget.toolTipsList2.isNotEmpty &&
                          widget.toolTipsList2[adjustedGroupIndex].isNotEmpty) {
                        tooltipText += "\n--------------\nDiastolic updating:";
                        for (ToolTip toolTip in widget.toolTipsList2[adjustedGroupIndex]) {
                          String additionalText =
                              "\n${toolTip.time} - ${toolTip.val.toString()}";
                          tooltipText += additionalText;
                        }
                      }

                      return BarTooltipItem(tooltipText, TextStyle(color: Colors.white));
                    },
                    fitInsideVertically: true,
                    fitInsideHorizontally: true,
                  ),
                  touchExtraThreshold: EdgeInsets.all(4),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: bottomTitleWidget,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: FlGridData(
                  show: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  List<_ChartData> _getChartData() {
    final List<_ChartData> chartData = [];

    for (int i = 0; i < Constants.lineNumber; i++) {
      final y1 = widget.yList[i];
      final y2 = widget.yList2[i];
      final x = widget.xList[i];

      chartData.add(_ChartData(x, y1, y2));
    }
    return chartData;
  }
}

class _ChartData {
  _ChartData(this.x, this.y1, this.y2);

  final String x;
  final double y1;
  final double y2;
}
