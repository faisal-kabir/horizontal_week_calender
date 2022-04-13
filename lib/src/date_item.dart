import 'package:flutter/material.dart';
import 'package:horizontal_week_calender/horizontal_week_calender.dart';
import 'package:horizontal_week_calender/src/utils/cache_stream.dart';
import 'package:horizontal_week_calender/src/utils/compare_date.dart';

import 'cache_stream_widget.dart';

class DateItem extends StatefulWidget {
  /// Today
  final DateTime today;

  /// Date of item
  final DateTime? date;

  /// Week of item
  final String? weekDay;

  /// Style of [date]
  final TextStyle? dateStyle;

  /// Style of [weekDay]
  final TextStyle? weekDayStyle;

  /// Style of [date]
  final DateViewStyle? dateViewStyle;

  /// Style of day after pressed
  final TextStyle? pressedDateStyle;

  /// Background
  final Color? backgroundColor;

  /// Specify a background if [date] is [today]
  final Color? todayBackgroundColor;

  /// Specify a background after pressed
  final Color? pressedBackgroundColor;

  /// Alignment a decoration
  final Alignment? decorationAlignment;

  /// Specify a shape
  final ShapeBorder? dayShapeBorder;

  /// [Callback] function for press event
  final void Function(DateTime)? onDatePressed;

  /// [Callback] function for long press event
  final void Function(DateTime)? onDateLongPressed;

  /// Decoration widget
  final Widget? decoration;

  final int index;

  /// [cacheStream] for emit date press event
  final CacheStream<DateTime?> cacheStream;

  DateItem({
    required this.today,
    required this.date,
    required this.weekDay,
    required this.index,
    required this.cacheStream,
    this.dateStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.weekDayStyle,
    this.dateViewStyle,
    this.pressedDateStyle,
    this.backgroundColor = Colors.transparent,
    this.todayBackgroundColor = Colors.orangeAccent,
    this.pressedBackgroundColor,
    this.decorationAlignment = FractionalOffset.center,
    this.dayShapeBorder,
    this.onDatePressed,
    this.onDateLongPressed,
    this.decoration,
  });

  @override
  __DateItemState createState() => __DateItemState();
}

class __DateItemState extends State<DateItem> {
  /// Default background
  Color? _defaultBackgroundColor;

  /// Default style
  TextStyle? _defaultTextStyle;

  @override
  Widget build(BuildContext context) {
    bool isSelected = false;
    return widget.date != null
        ? CacheStreamBuilder<DateTime?>(
      cacheStream: widget.cacheStream,
      cacheBuilder: (_, data) {
        /// Set default each [builder] is called
        _defaultBackgroundColor = widget.backgroundColor;

        /// Set default style each [builder] is called
        _defaultTextStyle = widget.dateStyle;

        /// Check and set [Background] of today
        final DateTime? dateSelected = data.data;
        isSelected = compareDate(widget.date, dateSelected);
        if (isSelected) {
          _defaultBackgroundColor = widget.pressedBackgroundColor;
          _defaultTextStyle = widget.pressedDateStyle;
        }
        return _body(isSelected);
      },
    )
        : Container(
      width: 50,
      height: 50,
    );
  }

  Widget weekView () {
    return Text(
      widget.weekDay!,
      style: widget.weekDayStyle,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  /// Body layout
  Widget _body(bool isSelected) => widget.dateViewStyle == DateViewStyle.Underlined ? Expanded(
    child: Column(
      children: [
        weekView(),
        Expanded(
          child: Container(
                alignment: FractionalOffset.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onLongPress: _onLongPressed,
                        child: TextButton(
                            onPressed: _onPressed,
                            child: Text(
                              '${widget.date!.day}',
                              style: _defaultTextStyle!,
                            )
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isSelected,
                      child: Container(
                        height: 2,
                        width: 20,
                        color: _defaultTextStyle!.color,
                      ),
                    )
                  ],
                ),
              ),
        ),
      ],
    ),
  ) : Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10).copyWith(right: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isSelected ? widget.pressedBackgroundColor : Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0.0,1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: _onLongPressed,
        borderRadius: BorderRadius.circular(5),
        child: GestureDetector(
          onTap: _onPressed,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    '${widget.date!.day}',
                    style: widget.dateStyle!.copyWith(color:isSelected ? Colors.white : widget.dateStyle!.color,),
                  ),
                ),
              ),
              Text(
                widget.weekDay!,
                style: TextStyle(color: isSelected ? Colors.white : widget.weekDayStyle!.color,fontSize: 12,fontWeight: FontWeight.w500,fontFamily: widget.weekDayStyle!.fontFamily),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Handler press event
  void _onPressed() {
    if (widget.date != null) {
      widget.cacheStream.add(widget.date);
      widget.onDatePressed!(widget.date!);
    }
  }

  /// Handler long press event
  void _onLongPressed() {
    if (widget.date != null) {
      widget.cacheStream.add(widget.date);
      widget.onDateLongPressed!(widget.date!);
    }
  }
}
