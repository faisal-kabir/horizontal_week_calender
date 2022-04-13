import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:horizontal_week_calender/horizontal_week_calender.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  WeekCalendarController controller = WeekCalendarController();

  @override
  void initState() {
    super.initState();
    controller.selectedDate= DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          title: const Text('Horizontal Week Calender'),
        ),
        body: Column(
          children: [
            HorizontalWeekCalender(
              controller: controller,
              showMonth: true,
              minDate: DateTime.now().add(
                const Duration(days: -365),
              ),
              maxDate: DateTime.now().add(
                const Duration(days: 365),
              ),
              onDatePressed: (DateTime datetime) {
                // Do something
                setState(() {});
              },
              onDateLongPressed: (DateTime datetime) {
                // Do something
              },
              onWeekChanged: () {
                // Do something
              },
              dateViewStyle: DateViewStyle.Boxed,
              dayOfWeekStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500),
              pressedDateBackgroundColor: Color(0xFF25D366),
              todayButtonTextStyle: const TextStyle(
                color: Color(0xFF25D366),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              monthViewBuilder: (DateTime time) => Align(
                alignment: FractionalOffset.center,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    time.toString(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),)
                ),
              ),
              decorations: [
                DecorationItem(
                  decorationAlignment: FractionalOffset.center,
                  date: DateTime.now(),
                  decoration: const Icon(
                    Icons.today,
                    color: Colors.blue,
                  )
                ),
                DecorationItem(
                  date: DateTime.now().add(const Duration(days: 3)),
                  decoration: const Text('Holiday', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.w600,),)
                ),
              ],
            ),
          Expanded(
            child: Center(
              child: Text(
                '${controller.selectedDate!.day}/${controller.selectedDate!.month}/${controller.selectedDate!.year}',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.jumpToDate(DateTime.now());
            setState(() {});
          },
          child: const Icon(Icons.today),
        ),
      ),
    );
  }
}
