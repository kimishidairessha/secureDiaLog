import 'package:flutter/material.dart';
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

  State<DataTableWidget> createState() => _DataTableWidget();
}

class _DataTableWidget extends State<DataTableWidget> {
  final ScrollController controller = ScrollController();
  final ScrollController controller2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    int maxRows = widget.timeList.length + widget.strengthToolTipsList.length;
    int maxTooltipStrength = widget.strengthToolTipsList
        .fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipFasting = widget.fastingToolTipsList
        .fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipPostprandial = widget.postprandialToolTipsList
        .fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipSystolic = widget.systolicToolTipsList
        .fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipDiastolic = widget.diastolicToolTipsList
        .fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipWeight = widget.weightToolTipsList
        .fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipHeartRate = widget.heartRateToolTipsList
        .fold<int>(0, (max, list) => list.length > max ? list.length : max);

    return Scrollbar(
      controller: controller2,
      // isAlwaysShown: true,
      child: SingleChildScrollView(
        controller: controller2,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: controller,
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Data')),
              const DataColumn(label: Text('Time')),
              const DataColumn(label: Text('Strength Level')),
              const DataColumn(label: Text('Fasting Blood Glucose')),
              const DataColumn(label: Text('Postprandial Blood Glucose')),
              const DataColumn(label: Text('Systolic')),
              const DataColumn(label: Text('Diastolic')),
              const DataColumn(label: Text('Weight')),
              const DataColumn(label: Text('Heart Rate')),
            ],
            rows: createRows(),
          ),
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
          DataCell(Text(mapValueToText(widget.strengthList[rowIndex]))),
          DataCell(Text('${widget.fastingList[rowIndex]}')),
          DataCell(Text('${widget.postprandialList[rowIndex]}')),
          DataCell(Text('${widget.systolicList[rowIndex]}')),
          DataCell(Text('${widget.diastolicList[rowIndex]}')),
          DataCell(Text('${widget.weightList[rowIndex]}')),
          DataCell(Text('${widget.heartRateList[rowIndex]}')),
        ]));

        // Tooltip rows for strength
        for (int i = 0; i < widget.strengthToolTipsList[rowIndex].length; i++) {
          allRows.add(DataRow(cells: [
            DataCell(Text(widget.timeList[rowIndex])), // Date empty for tooltip rows
            DataCell(Text(TimeUtils.convertHHmmToClock(widget.strengthToolTipsList[rowIndex][i].time))), // Tooltip time
            DataCell(Text(mapValueToText(widget.strengthToolTipsList[rowIndex][i].val))), // Tooltip value
            DataCell(Text(setNull(widget.fastingToolTipsList[rowIndex][i].val))),
            DataCell(Text(setNull(widget.postprandialToolTipsList[rowIndex][i].val))),
            DataCell(Text(setNull(widget.systolicToolTipsList[rowIndex][i].val))),
            DataCell(Text(setNull(widget.diastolicToolTipsList[rowIndex][i].val))),
            DataCell(Text(setNull(widget.weightToolTipsList[rowIndex][i].val))),
            DataCell(Text(setNull(widget.heartRateToolTipsList[rowIndex][i].val))),
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
