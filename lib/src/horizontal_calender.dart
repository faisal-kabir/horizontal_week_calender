import 'dart:async';

import 'package:flutter/material.dart';
import 'models/decoration_item.dart';
import 'models/week_item.dart';
import 'date_item.dart';
import 'utils/find_current_week_index.dart';
import 'utils/separate_weeks.dart';
import 'utils/compare_date.dart';

import 'strings.dart';
import 'utils/cache_stream.dart';

class WeekCalendarController {
  /// Today date time
  DateTime _today = DateTime.now();

  /// Store hast attach to a client state
  bool _hasClient = false;

  /// Return [true] if attached to [HorizontalWeekCalender] widget
  bool get hasClient => _hasClient;

  /// Store a selected date
  DateTime? selectedDate;


  /// get [_weeks]
  List<DateTime?> get rangeWeekDate =>
      _weeks.isNotEmpty
          ? _weeks[_currentWeekIndex].days.where((ele) => ele != null).toList()
          : [];

  /// [Callback] for update widget event
  late Function(DateTime?) _widgetJumpToDate;

  /// Index of week display on the screen
  int _currentWeekIndex = 0;

  /// Store a list [DateTime] of weeks display on the screen
  final List<WeekItem> _weeks = [];

  bool prevMonthEnable=true;
  bool nextMonthEnable=true;

  /// [jumpToDate] show week contain [date] on the screen
  void jumpToDate(DateTime date) {
    /// Find [_newCurrentWeekIndex] corresponding new [dateTime]
    final _newCurrentWeekIndex = findCurrentWeekIndexByDate(date, _weeks);
    checkButtonVisibility(date);
    /// If has matched, update [_currentWeekIndex], [_selectedDate]
    /// and call [_widgetJumpToDate] for update widget
    if (_newCurrentWeekIndex != -1) {
      _currentWeekIndex = _newCurrentWeekIndex;

      selectedDate = date;

      /// Call [_widgetJumpToDate] for update Widget
      _widgetJumpToDate(selectedDate);
    }
  }

  void checkButtonVisibility(DateTime date){
    prevMonthEnable = findCurrentWeekIndexByDate(getDate(date,isPrev: true), _weeks) != -1 ;
    DateTime nextMonth = getDate(date);
    nextMonthEnable = !isLastMonth(nextMonth);
  }

  bool isLastMonth(DateTime nextMonth){
    try{
      bool isLast = false;
      for(int i=_weeks[_weeks.length-1].days.length-1; i>=0; i--){
        if(_weeks[_weeks.length-1].days[i]!=null){
          if(DateTime.utc(_weeks[_weeks.length-1].days[i]!.year,_weeks[_weeks.length-1].days[i]!.month,1).compareTo(nextMonth) == -1){
            isLast = true;
          }
          break;
        }
      }
      return isLast;
    } catch (e) {
      return false;
    }
  }


}

DateTime getDate(DateTime date,{bool isPrev=false}){
  int currentYear = date.year;
  int currentMonth = date.month;
  if(isPrev){
    if((currentMonth-1) < 1){
      currentYear --;
      currentMonth = 12;
    } else {
      currentMonth --;
    }
  } else {
    if(currentMonth > 12){
      currentYear ++;
      currentMonth = 1;
    } else {
      currentMonth ++;
    }
  }
  return DateTime.utc(currentYear, currentMonth, 1);
}

class HorizontalWeekCalender extends StatefulWidget {
  /// Calendar start from [minDate]
  final DateTime minDate;

  /// Calendar end at [maxDate]
  final DateTime maxDate;

  /// Style of months
  final Widget Function(DateTime)? monthViewBuilder;

  /// Style of day of week
  final TextStyle dayOfWeekStyle;

  /// Style of weekends days
  final TextStyle weekendsStyle;

  /// Alignment of day day of week
  final FractionalOffset monthAlignment;

  /// Style of dates
  final TextStyle dateStyle;

  /// Specify a style for today
  final TextStyle todayDateStyle;

  /// Specify a background for today
  final Color todayBackgroundColor;

  /// Specify background for date after pressed
  final Color datePressedBackgroundColor;

  /// Specify a style for date after pressed
  final TextStyle datePressedStyle;

  /// Background for dates
  final Color dateBackgroundColor;

  /// [Callback] function for press event
  final void Function(DateTime) onDatePressed;

  /// [Callback] function for long press even
  final void Function(DateTime) onDateLongPressed;

  /// Background color of calendar
  final Color backgroundColor;

  /// List contain titles day of week
  final List<String> daysOfWeek;

  /// List contain title months
  final List<String> months;

  /// Condition show month
  final bool monthDisplay;

  /// List contain indexes of weekends from days titles list
  final List<int> weekendsIndexes;

  /// Margin day of week row
  final EdgeInsets marginDayOfWeek;

  /// Margin month row
  final EdgeInsets marginMonth;

  /// Shape of day
  final ShapeBorder dayShapeBorder;

  /// List of decorations
  final List<DecorationItem> decorations;

  /// Height of calendar
  final double height;

  /// Page controller
  final WeekCalendarController? controller;

  /// [Callback] changed week event
  final Function() onWeekChanged;

  HorizontalWeekCalender._(Key? key,
      this.maxDate,
      this.minDate,
      this.height,
      this.monthViewBuilder,
      this.dayOfWeekStyle,
      this.monthAlignment,
      this.dateStyle,
      this.todayDateStyle,
      this.todayBackgroundColor,
      this.datePressedBackgroundColor,
      this.datePressedStyle,
      this.dateBackgroundColor,
      this.onDatePressed,
      this.onDateLongPressed,
      this.backgroundColor,
      this.daysOfWeek,
      this.months,
      this.monthDisplay,
      this.weekendsIndexes,
      this.weekendsStyle,
      this.marginMonth,
      this.marginDayOfWeek,
      this.dayShapeBorder,
      this.decorations,
      this.controller,
      this.onWeekChanged)
      : assert(daysOfWeek.length == 7),
        assert(months.length == 12),
        assert(minDate.isBefore(maxDate)),
        super(key: key);

  factory HorizontalWeekCalender({Key? key,
    DateTime? maxDate,
    DateTime? minDate,
    double height = 120,
    Widget Function(DateTime)? monthViewBuilder,
    TextStyle dayOfWeekStyle = const TextStyle(color: Color(0xffC3C9D7), fontWeight: FontWeight.w400, fontSize: 12),
    FractionalOffset monthAlignment = FractionalOffset.center,
    TextStyle dateStyle = const TextStyle(color: Color(0xFF2B344A), fontWeight: FontWeight.w700, fontSize: 17),
    TextStyle todayDateStyle = const TextStyle(color: Color(0xFF2B344A), fontWeight: FontWeight.w700, fontSize: 17),
    Color todayBackgroundColor = Colors.black12,
    Color pressedDateBackgroundColor = Colors.blue,
    TextStyle pressedDateStyle = const TextStyle(color: Color(0xFF0A6659), fontWeight: FontWeight.w700, fontSize: 17),
    Color dateBackgroundColor = Colors.transparent,
    Function(DateTime)? onDatePressed,
    Function(DateTime)? onDateLongPressed,
    Color backgroundColor = Colors.white,
    List<String> dayOfWeek = dayOfWeekDefault,
    List<String> month = monthDefaults,
    bool showMonth = true,
    List<int> weekendsIndexes = weekendsIndexesDefault,
    TextStyle weekendsStyle = const TextStyle(color: Color(0xFF2B344A), fontWeight: FontWeight.w700, fontSize: 17),
    EdgeInsets marginMonth = const EdgeInsets.symmetric(vertical: 4),
    EdgeInsets marginDayOfWeek = EdgeInsets.zero,
    CircleBorder dayShapeBorder = const CircleBorder(),
    List<DecorationItem> decorations = const [],
    WeekCalendarController? controller,
    Function()? onWeekChanged}) =>
      HorizontalWeekCalender._(
          key,
          maxDate ?? DateTime.now().add(Duration(days: 365)),
          minDate ?? DateTime.now().add(Duration(days: -365)),
          height,
          monthViewBuilder,
          dayOfWeekStyle,
          monthAlignment,
          dateStyle,
          todayDateStyle,
          todayBackgroundColor,
          pressedDateBackgroundColor,
          pressedDateStyle,
          dateBackgroundColor,
          onDatePressed ?? (DateTime date) {},
          onDateLongPressed ?? (DateTime date) {},
          backgroundColor,
          dayOfWeek,
          month,
          showMonth,
          weekendsIndexes,
          weekendsStyle,
          marginMonth,
          marginDayOfWeek,
          dayShapeBorder,
          decorations,
          controller,
          onWeekChanged ?? () {});

  @override
  _HorizontalWeekCalenderState createState() => _HorizontalWeekCalenderState();
}

class _HorizontalWeekCalenderState extends State<HorizontalWeekCalender> {
  /// [_streamController] for emit date press event
  final CacheStream<DateTime?> _cacheStream = CacheStream<DateTime?>();

  /// [_stream] for listen date change event
  Stream<DateTime?>? _stream;

  /// Page controller
  late PageController _pageController;

  WeekCalendarController _defaultCalendarController = WeekCalendarController();

  WeekCalendarController get controller =>
      widget.controller ?? _defaultCalendarController;

  void _jumToDateHandler(DateTime? dateTime) {
    _cacheStream.add(dateTime);
    _pageController.animateToPage(widget.controller!._currentWeekIndex,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }


  void _setUp() {
    assert(controller.hasClient == false);
    _stream ??= _cacheStream.stream!.asBroadcastStream();
    _cacheStream.add(controller._today);
    controller
      .._weeks.clear()
      .._weeks.addAll(separateWeeks(
          widget.minDate, widget.maxDate, widget.daysOfWeek, widget.months))

    /// [_currentWeekIndex] is index of week in [List] weeks contain today

      .._currentWeekIndex = findCurrentWeekIndexByDate(
          controller._today, controller._weeks)
      .._widgetJumpToDate = _jumToDateHandler
      .._hasClient = true;

    /// Init Page controller
    /// Set [initialPage] is page contain today
    _pageController = PageController(initialPage: controller._currentWeekIndex);
    checkButtonVisibility(controller._currentWeekIndex);
  }

  @override
  void initState() {
    super.initState();
    _setUp();
    _pageController.addListener(() {
      int page = _pageController.page!.toInt();
      //weekYear=controller._weeks[page].days[controller._weeks[page].days.length-1]!.year.toString();
      checkButtonVisibility(_pageController.page!.toInt());
    });
  }

  void checkButtonVisibility(int page){
    DateTime? date;
    for(int i=controller._weeks[page].days.length-1; i>=0; i--){
      if(controller._weeks[page].days[i]!=null){
        date = controller._weeks[page].days[i];
        break;
      }
    }
    controller.checkButtonVisibility(date!);
  }


  @override
  Widget build(BuildContext context) => _body();

  /// Body layout
  Widget _body() =>
      Container(
          color: widget.backgroundColor,
          width: double.infinity,
          height: widget.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.all(16).copyWith(top: 20,bottom: 20),
                  child: Row(
                    children: [
                      Expanded(child: Row(
                        children: [
                          InkWell(
                              onTap: widget.controller!.prevMonthEnable ? (){
                                DateTime date = getDate(controller._weeks[_pageController.page!.toInt()].days[controller._weeks[_pageController.page!.toInt()].days.length-1]!,isPrev:true);
                                widget.controller!.jumpToDate(date);
                                widget.onDatePressed(date);
                              } : null,
                              child: Icon(Icons.arrow_back_ios_new_rounded,color: widget.controller!.prevMonthEnable ? Colors.black : Colors.grey,size: 18,)
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5,right: 5),
                            child: Text('${controller._weeks[controller._currentWeekIndex].month} ${controller._weeks[controller._currentWeekIndex].days[0]!.year}',style: TextStyle(fontSize: 14,color: Color(0xFF2B344A),fontWeight: FontWeight.w700),),
                          ),
                          InkWell(
                              onTap: widget.controller!.nextMonthEnable ? (){
                                DateTime date = getDate(controller._weeks[_pageController.page!.toInt()].days[controller._weeks[_pageController.page!.toInt()].days.length-1]!);
                                widget.controller!.jumpToDate(date);
                                widget.onDatePressed(date);
                              } : null,
                              child: Icon(Icons.arrow_forward_ios_rounded,color: widget.controller!.nextMonthEnable ? Colors.black : Colors.grey,size: 18,)
                          ),
                        ],
                      )),
                      InkWell(
                        onTap: () {
                          widget.controller!.jumpToDate(controller._today);
                          widget.onDatePressed(controller._today);
                        },
                        child: Text('Today',style: TextStyle(color: Colors.blue,fontSize: 14,)),
                      ),
                      SizedBox(width: 10,)
                    ],
                  )
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: controller._weeks.length,
                  onPageChanged: (currentPage) {
                    widget.controller!._currentWeekIndex = currentPage;
                    widget.onWeekChanged();
                  },
                  itemBuilder: (_, i) => _week(controller._weeks[i]),
                ),
              ),
            ],
          )
      );

  /// Layout of week
  Widget _week(WeekItem weeks) =>
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Month
            /*(widget.monthDisplay && widget.monthViewBuilder != null &&
                weeks.days.firstWhere((el) => el != null) != null)
                ? widget
                .monthViewBuilder!(weeks.days.firstWhere((el) => el != null)!)
                : _monthItem(weeks.month),*/

            /// Day of week layout
            _dayOfWeek(weeks.dayOfWeek),

            /// Date layout
            _dates(weeks.days)
          ],
        ),
      );

  /// Day of week item layout
  Widget _monthItem(String title) =>
      Align(
        alignment: widget.monthAlignment,
        child: Container(
            margin: widget.marginMonth,
            child: Text(
              title,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )),
      );

  /// Day of week layout
  Widget _dayOfWeek(List<String> dayOfWeek) =>
      Container(
        margin: widget.marginDayOfWeek,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayOfWeek.map(_dayOfWeekItem).toList()),
      );

  /// Day of week item layout
  Widget _dayOfWeekItem(String title) =>
      Container(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 50,
              child: Text(
                title,
                style: widget.dayOfWeekStyle,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ));

  /// Date layout
  Widget _dates(List<DateTime?> dates) =>
      Expanded(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dates.map(_dateItem).toList()
        ),
      );

  /// Date item layout
  Widget _dateItem(DateTime? date) =>
      DateItem(
          today: controller._today,
          date: date,
          dateStyle: compareDate(date, controller._today)
              ? widget.todayDateStyle
              : date != null && (date.weekday == 6 || date.weekday == 7)
              ? widget.weekendsStyle
              : widget.dateStyle,
          pressedDateStyle: widget.datePressedStyle,
          backgroundColor: widget.dateBackgroundColor,
          todayBackgroundColor: widget.todayBackgroundColor,
          pressedBackgroundColor: widget.datePressedBackgroundColor,
          decorationAlignment: () {
            /// If date is contain in decorations list, use decorations Alignment
            if (widget.decorations.isNotEmpty) {
              final List<DecorationItem> matchDate = widget.decorations
                  .where((ele) => compareDate(ele.date, date))
                  .toList();
              return matchDate.isNotEmpty
                  ? matchDate[0].decorationAlignment
                  : FractionalOffset.center;
            }
            return FractionalOffset.center;
          }(),
          dayShapeBorder: widget.dayShapeBorder,
          onDatePressed: (datePressed) {
            controller.selectedDate = datePressed;
            widget.onDatePressed(datePressed);
          },
          onDateLongPressed: (datePressed) {
            controller.selectedDate = datePressed;
            widget.onDateLongPressed(datePressed);
          },
          decoration: () {
            /// If date is contain in decorations list, use decorations Widget
            if (widget.decorations.isNotEmpty) {
              final List<DecorationItem> matchDate = widget.decorations
                  .where((ele) => compareDate(ele.date, date))
                  .toList();
              return matchDate.isNotEmpty ? matchDate[0].decoration : null;
            }
            return null;
          }(),
          cacheStream: _cacheStream);

  @override
  void dispose() {
    super.dispose();
    _cacheStream.close();
  }
}
