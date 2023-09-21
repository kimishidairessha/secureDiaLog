import 'package:flutter/material.dart';
import 'package:securedialog/model/tooltip.dart';
import 'package:securedialog/utils/time_utils.dart';

class DataTableWidget extends StatefulWidget{
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

  const DataTableWidget(this.timeList, this.strengthTimeList, this.strengthList,
      this.fastingList, this.fastingTimeList, this.postprandialList,
      this.postprandialTimeList, this.diastolicList, this.diastolicTimeList,
      this.weightList, this.weightTimeList, this.systolicList,
      this.systolicTimeList, this.heartRateList, this.heartRateTimeList,
      this.strengthToolTipsList, this.fastingToolTipsList,
      this.postprandialToolTipsList, this.diastolicToolTipsList,
      this.weightToolTipsList, this.systolicToolTipsList,
      this.heartRateToolTipsList, {Key? key})
      : super(key: key);

  State<DataTableWidget> createState() =>
      _DataTableWidget();
  
}

class _DataTableWidget extends State<DataTableWidget>{
  final ScrollController controller = ScrollController();
  final ScrollController controller2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    int maxRows = widget.timeList.length;
    int maxTooltipStrength = widget.strengthToolTipsList.fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipFasting = widget.fastingToolTipsList.fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipPostprandial = widget.postprandialToolTipsList.fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipSystolic = widget.systolicToolTipsList.fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipDiastolic = widget.diastolicToolTipsList.fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipWeight = widget.weightToolTipsList.fold<int>(0, (max, list) => list.length > max ? list.length : max);
    int maxTooltipHeartRate = widget.heartRateToolTipsList.fold<int>(0, (max, list) => list.length > max ? list.length : max);

    return Scrollbar(
        controller: controller2,
        isAlwaysShown: true,
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
                  ...List.generate(maxTooltipStrength, (index) => DataColumn(label: Text('Updating(Time) ${index + 1}'))),
                  const DataColumn(label: Text('Time')),
                  const DataColumn(label: Text('Fasting Blood Glucose')),
                  ...List.generate(maxTooltipFasting, (index) => DataColumn(label: Text('Updating(Time) ${index + 1}'))),
                  const DataColumn(label: Text('Time')),
                  const DataColumn(label: Text('Postprandial Blood Glucose')),
                  ...List.generate(maxTooltipPostprandial, (index) => DataColumn(label: Text('Updating(Time) ${index + 1}'))),
                  const DataColumn(label: Text('Time')),
                  const DataColumn(label: Text('Systolic')),
                  ...List.generate(maxTooltipSystolic, (index) => DataColumn(label: Text('Updating(Time) ${index + 1}'))),
                  const DataColumn(label: Text('Time')),
                  const DataColumn(label: Text('Diastolic')),
                  ...List.generate(maxTooltipDiastolic, (index) => DataColumn(label: Text('Updating(Time) ${index + 1}'))),
                  const DataColumn(label: Text('Time')),
                  const DataColumn(label: Text('Weight')),
                  ...List.generate(maxTooltipWeight, (index) => DataColumn(label: Text('Updating(Time) ${index + 1}'))),
                  const DataColumn(label: Text('Time')),
                  const DataColumn(label: Text('Heart Rate')),
                  ...List.generate(maxTooltipHeartRate, (index) => DataColumn(label: Text('Updating(Time) ${index + 1}'))),
                ],
                rows: List.generate(maxRows, (rowIndex) => rowIndex)
                    .where((rowIndex) => widget.strengthTimeList[rowIndex] != 'none') // Filter out rows where timeList is '0'
                    .map((rowIndex) => DataRow(cells: [
                  DataCell(Text(widget.timeList[rowIndex])),
                  DataCell(Text(widget.strengthTimeList[rowIndex])),
                  DataCell(Text(mapValueToText(widget.strengthList[rowIndex]))),
                  ...List.generate(maxTooltipStrength, (index) {
                    if (index < widget.strengthToolTipsList[rowIndex].length) {
                      return DataCell(Text('${mapValueToText(widget.strengthToolTipsList[rowIndex][index].val)} (${TimeUtils.convertHHmmToClock(widget.strengthToolTipsList[rowIndex][index].time)})'));
                    } else {
                      return const DataCell(Text('')); // Empty cell for rows with fewer tooltips
                    }
                  }),
                  DataCell(Text(widget.fastingTimeList[rowIndex])),
                  DataCell(Text('${widget.fastingList[rowIndex]}')),
                  ...List.generate(maxTooltipFasting, (index) {
                    if (index < widget.fastingToolTipsList[rowIndex].length) {
                      return DataCell(Text('${setNull(widget.fastingToolTipsList[rowIndex][index].val)} (${TimeUtils.convertHHmmToClock(widget.fastingToolTipsList[rowIndex][index].time)})'));
                    } else {
                      return const DataCell(Text('')); // Empty cell for rows with fewer tooltips
                    }
                  }),
                  DataCell(Text(widget.postprandialTimeList[rowIndex])),
                  DataCell(Text('${widget.postprandialList[rowIndex]}')),
                  ...List.generate(maxTooltipPostprandial, (index) {
                    if (index < widget.postprandialToolTipsList[rowIndex].length) {
                      return DataCell(Text('${setNull(widget.postprandialToolTipsList[rowIndex][index].val)} (${TimeUtils.convertHHmmToClock(widget.postprandialToolTipsList[rowIndex][index].time)})'));
                    } else {
                      return const DataCell(Text('')); // Empty cell for rows with fewer tooltips
                    }
                  }),
                  DataCell(Text(widget.systolicTimeList[rowIndex])),
                  DataCell(Text('${widget.systolicList[rowIndex]}')),
                  ...List.generate(maxTooltipSystolic, (index) {
                    if (index < widget.systolicToolTipsList[rowIndex].length) {
                      return DataCell(Text('${setNull(widget.systolicToolTipsList[rowIndex][index].val)} (${TimeUtils.convertHHmmToClock(widget.systolicToolTipsList[rowIndex][index].time)})'));
                    } else {
                      return const DataCell(Text('')); // Empty cell for rows with fewer tooltips
                    }
                  }),
                  DataCell(Text(widget.diastolicTimeList[rowIndex])),
                  DataCell(Text('${widget.diastolicList[rowIndex]}')),
                  ...List.generate(maxTooltipDiastolic, (index) {
                    if (index < widget.diastolicToolTipsList[rowIndex].length) {
                      return DataCell(Text('${setNull(widget.diastolicToolTipsList[rowIndex][index].val)} (${TimeUtils.convertHHmmToClock(widget.diastolicToolTipsList[rowIndex][index].time)})'));
                    } else {
                      return const DataCell(Text('')); // Empty cell for rows with fewer tooltips
                    }
                  }),
                  DataCell(Text(widget.weightTimeList[rowIndex])),
                  DataCell(Text('${widget.weightList[rowIndex]}')),
                  ...List.generate(maxTooltipWeight, (index) {
                    if (index < widget.weightToolTipsList[rowIndex].length) {
                      return DataCell(Text('${setNull(widget.weightToolTipsList[rowIndex][index].val)} (${TimeUtils.convertHHmmToClock(widget.weightToolTipsList[rowIndex][index].time)})'));
                    } else {
                      return const DataCell(Text('')); // Empty cell for rows with fewer tooltips
                    }
                  }),
                  DataCell(Text(widget.heartRateTimeList[rowIndex])),
                  DataCell(Text('${widget.heartRateList[rowIndex]}')),
                  ...List.generate(maxTooltipHeartRate, (index) {
                    if (index < widget.heartRateToolTipsList[rowIndex].length) {
                      return DataCell(Text('${setNull(widget.heartRateToolTipsList[rowIndex][index].val)} (${TimeUtils.convertHHmmToClock(widget.heartRateToolTipsList[rowIndex][index].time)})'));
                    } else {
                      return const DataCell(Text('')); // Empty cell for rows with fewer tooltips
                    }
                  }),
                ])).toList(),
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
    if (value == -1.0){
      return 'Null';
    } else {
      return value.toString();
    }
  }


}