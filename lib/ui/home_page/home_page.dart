import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:klee/ui/home_page/home_osm.dart';
import 'package:klee/ui/home_page/home_profile.dart';
import 'package:klee/ui/home_page/home_survey.dart';
import 'package:klee/utils/base_widget.dart';
import 'package:klee/utils/notify_utils.dart';
import 'package:klee/utils/survey_utils.dart';
import 'package:klee/utils/time_utils.dart';

import '../../service/home_page_service.dart';

/// the view layer of home page, a stateful widget
class HomePage extends StatefulWidget {
  final Map<dynamic, dynamic>? authData;

  const HomePage(this.authData, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageService homePageService = HomePageService();
  List<Widget> widgetList = <Widget>[];
  int curWidgetIdx = 1;

  @override
  void initState() {
    super.initState();
    widgetList
      ..add(HomeSurvey(widget.authData))
      ..add(HomeOSM(widget.authData))
      ..add(HomeProfile(widget.authData));
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: receiveMethod,
    );
    NotifyUtils.scheduleNotifications();
  }

  Future<void> receiveMethod(ReceivedAction receivedAction) async {
    String? lastSurveyTime =
        await SurveyUtils.getLastSurveyTime(widget.authData);
    String? currentTime = TimeUtils.getFormattedTimeYYYYmmDD(DateTime.now());
    if (lastSurveyTime == currentTime) {
      await showDialog<bool>(
          context: context,
          builder: (context) {
            return BaseWidget.getNoticeDialog(
                context,
                "Message",
                "Thank you for reporting today, please come back tomorrow ^_^",
                "Got it");
          });
      setState(() {
        curWidgetIdx = 1;
      });
    } else {
      setState(() {
        curWidgetIdx = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseWidget.getAppBar("Klee Compass"),
      body: IndexedStack(
        index: curWidgetIdx,
        children: widgetList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: curWidgetIdx,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: "Q&A",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.zoom_in_map),
            label: "MAP",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "POD",
          )
        ],
        onTap: _onTapEvent,
      ),
    );
  }

  /// tap event logic when taping bottomNavigationBar, set selected idx to current idx
  /// @param selectedIdx - selected index of the bottomNavigationBar
  /// @return void
  Future<void> _onTapEvent(int selectedIdx) async {
    if (selectedIdx == 0) {
      String? lastSurveyTime =
          await SurveyUtils.getLastSurveyTime(widget.authData);
      String? currentTime = TimeUtils.getFormattedTimeYYYYmmDD(DateTime.now());
      if (lastSurveyTime == currentTime) {
        bool? isGoBack = await showDialog<bool>(
            context: context,
            builder: (context) {
              return BaseWidget.getConfirmationDialog(
                  context,
                  "Message",
                  "Thank you for reporting condition today ^_^ Would you like to submit a new report?",
                  "New report",
                  "Come back tmr");
            });
        if (isGoBack == null || isGoBack || !mounted) {
          return;
        }
      }
    }
    setState(() {
      curWidgetIdx = selectedIdx;
    });
  }
}
