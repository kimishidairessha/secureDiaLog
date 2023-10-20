/// The widget for displaying a columned chart
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
import 'package:securedialog/constants/app.dart';
import '../../../model/tooltip.dart';
import '../../../utils/time_utils.dart';

class ColumnChartWidget extends StatefulWidget {
  final List<double> yList;
  final List<String> timeList;
  final List<String> xList;
  final double maxY;
  final List<List<ToolTip>> toolTipsList;

  const ColumnChartWidget(
      this.yList, this.timeList, this.xList, this.maxY, this.toolTipsList,
      {Key? key})
      : super(key: key);

  @override
  State<ColumnChartWidget> createState() =>
      _ColumnChartWidgetState();
}

class _ColumnChartWidgetState
    extends State<ColumnChartWidget> {
  late List<BarChartGroupData> rawBarGroups;
  late ScrollController scrollController;
  late List<BarChartGroupData> visibleBarGroups;

  int visibleLength = 7;
  int? selectedBarIndex;

  Widget bottomTitleWidget(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.teal,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text = const Text('');
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
    rawBarGroups = [];
    for (int i = 0; i < widget.yList.length; i++) {
      rawBarGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
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

    return Column(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal, // makes it horizontally scrollable
          child: SizedBox(
            height: 200,
            width: 38 * rawBarGroups.length.toDouble(),
            // constraints: BoxConstraints(
            //   minWidth:  // dynamic minWidth
            // ),
            child: BarChart(
              BarChartData(
                maxY: 10,
                barGroups: visibleBarGroups,
                barTouchData: BarTouchData(
                  touchCallback: (FlTouchEvent event, BarTouchResponse? touchResponse) {
                    if (touchResponse != null && touchResponse.spot != null) {
                      setState(() {
                        selectedBarIndex = touchResponse.spot!.touchedBarGroupIndex + firstVisibleDataIndex;
                        print("Selected bar index: $selectedBarIndex");
                      });
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.green[600],
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      print("Group index: $groupIndex, Rod index: $rodIndex");
                      int adjustedGroupIndex = groupIndex + firstVisibleDataIndex;
                      print(adjustedGroupIndex);
                      String time = widget.timeList[adjustedGroupIndex];
                      String strength = mapIntToValueString(widget.yList[adjustedGroupIndex]);

                      String tooltipText =
                          "$time\nStrength level: $strength";

                      return BarTooltipItem(tooltipText, const TextStyle(color: Colors.white));
                    },
                    fitInsideVertically: true,
                    fitInsideHorizontally: true,
                  ),
                  touchExtraThreshold: const EdgeInsets.all(4),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: bottomTitleWidget,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: const FlGridData(
                  show: false,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),

        if (selectedBarIndex != null) ...[
          const Text(
            "Detailed Strength level Updates(Time - value):",
            style: TextStyle(
              color: Colors.blueAccent,
              fontFamily: "KleeOne",
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.toolTipsList[selectedBarIndex!]
                .take(4)
                .toList()
                .map((toolTip) =>
            "${TimeUtils.convertHHmmToClock(toolTip.time)} - ${mapIntToValueString(toolTip.val)}")
                .join(', '),
            style: const TextStyle(
              color: Colors.teal,
              fontFamily: "KleeOne",
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );

  }

  List<_ChartData> _getChartData() {
    final List<_ChartData> chartData = [];

    for (int i = 0; i < Constants.lineNumber; i++) {
      final y1 = widget.yList[i];
      final x = widget.xList[i];

      chartData.add(_ChartData(x, y1));
    }
    return chartData;
  }

  String mapIntToValueString(double value) {
    switch (value.toInt()) {
      case 0:
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
        return 'Unknown'; // handle any other values not in your set
    }
  }
}

class _ChartData {
  _ChartData(this.x, this.y1);

  final String x;
  final double y1;
}
