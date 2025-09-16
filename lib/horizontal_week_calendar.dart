import 'dart:developer' show log;

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';

import 'convert_number_extension.dart';

enum WeekStartFrom {
  sunday,
  monday,
  friday,
}

class HorizontalWeekCalendar extends StatefulWidget {
  /// week start from Monday, Sunday, or Friday
  ///
  /// default value is
  /// ```dart
  /// [WeekStartFrom.monday]
  /// ```
  final WeekStartFrom? weekStartFrom;

  ///get DateTime on date select
  ///
  /// ```dart
  /// onDateChange: (DateTime date){
  ///    log(date);
  /// }
  /// ```
  final Function(DateTime)? onDateChange;

  ///get the list of DateTime on week change
  ///
  /// ```dart
  /// onWeekChange: (List<DateTime> list){
  ///    log("First date: ${list.first}");
  ///    log("Last date: ${list.last}");
  /// }
  /// ```
  final Function(List<DateTime>)? onWeekChange;

  /// Active background color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeBackgroundColor;

  /// In-Active background color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withValues(alpha: .2)
  /// ```
  final Color? inactiveBackgroundColor;

  /// Disable background color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? disabledBackgroundColor;

  /// Active text color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeTextColor;

  /// In-Active text color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withValues(alpha: .2)
  /// ```
  final Color? inactiveTextColor;

  /// Disable text color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? disabledTextColor;

  /// Active Navigator color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeNavigatorColor;

  /// In-Active Navigator color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? inactiveNavigatorColor;

  /// Month Color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withValues(alpha: .2)
  /// ```
  final Color? monthColor;

  /// border radius of date card
  ///
  /// Default value is `null`
  final BorderRadiusGeometry? borderRadius;

  /// scroll physics
  ///
  /// Default value is
  /// ```
  /// scrollPhysics: const ClampingScrollPhysics(),
  /// ```
  final ScrollPhysics? scrollPhysics;

  /// showNavigationButtons
  ///
  /// Default value is `true`
  final bool? showNavigationButtons;

  /// monthFormat
  ///
  /// If it's current year then
  /// Default value will be ```MMMM```
  ///
  /// Otherwise
  /// Default value will be `MMMM yyyy`
  final String? monthFormat;

  final DateTime minDate;

  final DateTime maxDate;

  final DateTime initialDate;

  final bool showTopNavbar;

  final HorizontalWeekCalenderController? controller;

  final double? carouselHeight;
  final double? itemMarginHorizontal;
  final Color? itemBorderColor;

  /// Whether to translate numbers according to the specified language
  ///
  /// Default value is `false`
  final bool translateNumbers;

  /// Language code for number translation
  ///
  /// Supported languages: 'ar', 'en', 'bn', 'ur'
  /// Default value is `'en'`
  final String languageCode;

  /// Custom day names starting from Sunday
  /// Must contain exactly 7 names: [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
  /// If null, default Arabic names will be used
  final List<String>? customDayNames;

  /// Custom month names for Hijri calendar starting from Muharram
  /// Must contain exactly 12 names: [Muharram, Safar, Rabi' al-awwal, ...]
  /// If null, default Arabic names will be used
  final List<String>? customMonthNames;

  /// Text style for day numbers
  ///
  /// Default value is `null` (uses theme default)
  final TextStyle? dayTextStyle;

  /// Text style for day names (Sun, Mon, etc.)
  ///
  /// Default value is `null` (uses theme default)
  final TextStyle? dayNameTextStyle;

  /// Text style for month display in top navbar
  ///
  /// Default value is `null` (uses theme default)
  final TextStyle? monthTextStyle;

  ///controll the date jump
  ///
  /// ```dart
  /// jumpPre()
  /// Jump scoll calender to left
  ///
  /// jumpNext()
  /// Jump calender to right date
  /// ```

  HorizontalWeekCalendar({
    super.key,
    this.onDateChange,
    this.onWeekChange,
    this.activeBackgroundColor,
    this.controller,
    this.inactiveBackgroundColor,
    this.disabledBackgroundColor = Colors.grey,
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = Colors.white,
    this.disabledTextColor = Colors.white,
    this.activeNavigatorColor,
    this.inactiveNavigatorColor,
    this.monthColor,
    this.weekStartFrom = WeekStartFrom.monday,
    this.borderRadius,
    this.scrollPhysics = const ClampingScrollPhysics(),
    this.showNavigationButtons = true,
    this.monthFormat,
    required this.minDate,
    required this.maxDate,
    required this.initialDate,
    this.showTopNavbar = true,
    this.carouselHeight,
    this.itemMarginHorizontal,
    this.itemBorderColor,
    this.translateNumbers = false,
    this.languageCode = 'en',
    this.customDayNames,
    this.customMonthNames,
    this.dayTextStyle,
    this.dayNameTextStyle,
    this.monthTextStyle,
  })  :
        // assert(minDate != null && maxDate != null),
        assert(minDate.isBefore(maxDate)),
        assert(
            minDate.isBefore(initialDate) && (initialDate).isBefore(maxDate)),
        super();

  @override
  State<HorizontalWeekCalendar> createState() => _HorizontalWeekCalendarState();
}

class _HorizontalWeekCalendarState extends State<HorizontalWeekCalendar> {
  CarouselSliderController carouselController = CarouselSliderController();

  final int _initialPage = 1;

  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now();
  List<DateTime> currentWeek = [];
  int currentWeekIndex = 0;

  List<List<DateTime>> listOfWeeks = [];

  HijriCalendarConfig dateTimeToHijri(DateTime date) {
    return HijriCalendarConfig.fromGregorian(date);
  }

  // Helper functions for Hijri calendar
  String getHijriDayName(DateTime date) {
    // Get the day index (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
    int dayIndex = date.weekday % 7;

    // Use custom day names if provided
    if (widget.customDayNames != null && widget.customDayNames!.length == 7) {
      return widget.customDayNames![dayIndex];
    }

    // Fallback to default Arabic names (starting from Sunday)
    final List<String> arabicDayNames = [
      'الأحد', // Sunday (0)
      'الإثنين', // Monday (1)
      'الثلاثاء', // Tuesday (2)
      'الأربعاء', // Wednesday (3)
      'الخميس', // Thursday (4)
      'الجمعة', // Friday (5)
      'السبت' // Saturday (6)
    ];
    return arabicDayNames[dayIndex];
  }

  String getHijriMonthName(HijriCalendarConfig hijriDate) {
    // Use custom month names if provided
    if (widget.customMonthNames != null &&
        widget.customMonthNames!.length == 12) {
      return widget.customMonthNames![hijriDate.hMonth - 1];
    }

    // Fallback to default Arabic names
    final List<String> arabicMonthNames = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة'
    ];
    return arabicMonthNames[hijriDate.hMonth - 1];
  }

  @override
  void initState() {
    initCalender();
    super.initState();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  initCalender() {
    final date = widget.initialDate;
    selectedDate = widget.initialDate;

    DateTime startOfCurrentWeek;

    switch (widget.weekStartFrom) {
      case WeekStartFrom.monday:
        startOfCurrentWeek =
            getDate(date.subtract(Duration(days: date.weekday - 1)));
        break;
      case WeekStartFrom.sunday:
        startOfCurrentWeek =
            getDate(date.subtract(Duration(days: date.weekday % 7)));
        break;
      case WeekStartFrom.friday:
        // Friday is weekday 5, we need to calculate days back to Friday
        // weekday: 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday, 7=Sunday
        int daysBackToFriday;
        if (date.weekday >= 5) {
          // If today is Friday, Saturday, or Sunday
          daysBackToFriday = date.weekday - 5;
        } else {
          // If today is Monday-Thursday, go back to previous Friday
          daysBackToFriday = date.weekday + 2;
        }
        startOfCurrentWeek =
            getDate(date.subtract(Duration(days: daysBackToFriday)));
        break;
      default:
        startOfCurrentWeek =
            getDate(date.subtract(Duration(days: date.weekday - 1)));
    }

    currentWeek.add(startOfCurrentWeek);
    for (int index = 0; index < 6; index++) {
      DateTime addDate = startOfCurrentWeek.add(Duration(days: (index + 1)));
      currentWeek.add(addDate);
    }

    listOfWeeks.add(currentWeek);

    _getMorePreviousWeeks();

    _getMoreNextWeeks();

    if (widget.controller != null) {
      widget.controller!._stateChangerPre.addListener(() {
        log("previous");
        _onBackClick();
      });

      widget.controller!._stateChangerNex.addListener(() {
        log("next");
        _onNextClick();
      });
    }
  }

  _getMorePreviousWeeks() {
    List<DateTime> minus7Days = [];
    DateTime startFrom = listOfWeeks[currentWeekIndex].first;

    bool canAdd = false;
    for (int index = 0; index < 7; index++) {
      DateTime minusDate = startFrom.add(Duration(days: -(index + 1)));
      minus7Days.add(minusDate);
      // if (widget.minDate != null) {
      if (minusDate.add(const Duration(days: 1)).isAfter(widget.minDate)) {
        canAdd = true;
      }
      // } else {
      //   canAdd = true;
      // }
    }
    if (canAdd == true) {
      listOfWeeks.add(minus7Days.reversed.toList());
    }
    setState(() {});
  }

  _getMoreNextWeeks() {
    List<DateTime> plus7Days = [];
    // DateTime startFrom = currentWeek.last;
    DateTime startFrom = listOfWeeks[currentWeekIndex].last;

    // bool canAdd = false;
    // int newCurrentWeekIndex = 1;
    for (int index = 0; index < 7; index++) {
      DateTime addDate = startFrom.add(Duration(days: (index + 1)));
      plus7Days.add(addDate);
      // if (widget.maxDate != null) {
      //   if (addDate.isBefore(widget.maxDate!)) {
      //     canAdd = true;
      //     newCurrentWeekIndex = 1;
      //   } else {
      //     newCurrentWeekIndex = 0;
      //   }
      // } else {
      //   canAdd = true;
      //   newCurrentWeekIndex = 1;
      // }
    }
    // log("canAdd: $canAdd");
    // log("newCurrentWeekIndex: $newCurrentWeekIndex");

    // if (canAdd == true) {
    listOfWeeks.insert(0, plus7Days);
    // }
    currentWeekIndex = 1;
    setState(() {});
  }

  _onDateSelect(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    widget.onDateChange?.call(selectedDate);
  }

  _onBackClick() {
    carouselController.nextPage();
  }

  _onNextClick() {
    carouselController.previousPage();
  }

  onWeekChange(index) {
    if (currentWeekIndex < index) {
      // on back
    }
    if (currentWeekIndex > index) {
      // on next
    }

    currentWeekIndex = index;
    currentWeek = listOfWeeks[currentWeekIndex];

    if (currentWeekIndex + 1 == listOfWeeks.length) {
      _getMorePreviousWeeks();
    }

    if (index == 0) {
      _getMoreNextWeeks();
      carouselController.nextPage();
    }

    widget.onWeekChange?.call(currentWeek);
    setState(() {});
  }

  // =================

  bool _isReachMinimum(DateTime dateTime) {
    return widget.minDate.add(const Duration(days: -1)).isBefore(dateTime);
  }

  bool _isReachMaximum(DateTime dateTime) {
    return widget.maxDate.add(const Duration(days: 1)).isAfter(dateTime);
  }

  bool _isNextDisabled() {
    DateTime lastDate = listOfWeeks[currentWeekIndex].last;
    // if (widget.maxDate != null) {
    String lastDateFormatted = DateFormat('yyyy/MM/dd').format(lastDate);
    String maxDateFormatted = DateFormat('yyyy/MM/dd').format(widget.maxDate);
    if (lastDateFormatted == maxDateFormatted) return true;
    // }

    bool isAfter =
        // widget.maxDate == null ? false :
        lastDate.isAfter(widget.maxDate);

    return isAfter;
    // return listOfWeeks[currentWeekIndex].last.isBefore(DateTime.now());
  }

  bool isBackDisabled() {
    DateTime firstDate = listOfWeeks[currentWeekIndex].first;
    // if (widget.minDate != null) {
    String firstDateFormatted = DateFormat('yyyy/MM/dd').format(firstDate);
    String minDateFormatted = DateFormat('yyyy/MM/dd').format(widget.minDate);
    if (firstDateFormatted == minDateFormatted) return true;
    // }

    bool isBefore =
        // widget.minDate == null ? false :
        firstDate.isBefore(widget.minDate);

    return isBefore;
    // return listOfWeeks[currentWeekIndex].last.isBefore(DateTime.now());
  }

  isCurrentYear() {
    return dateTimeToHijri(currentWeek.first).hYear ==
        dateTimeToHijri(today).hYear;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // var withOfScreen = MediaQuery.of(context).size.width;

    // double boxHeight = withOfScreen / 7;

    return currentWeek.isEmpty
        ? const SizedBox()
        : Column(
            children: [
              if (widget.showTopNavbar)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.showNavigationButtons == true
                        ? GestureDetector(
                            onTap: isBackDisabled()
                                ? null
                                : () {
                                    _onBackClick();
                                  },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 17,
                                  color: isBackDisabled()
                                      ? (widget.inactiveNavigatorColor ??
                                          Colors.grey)
                                      : theme.primaryColor,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "Back",
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: isBackDisabled()
                                        ? (widget.inactiveNavigatorColor ??
                                            Colors.grey)
                                        : theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    Text(
                      widget.monthFormat?.isEmpty ?? true
                          ? (isCurrentYear()
                              ? getHijriMonthName(
                                  dateTimeToHijri(currentWeek.first))
                              : widget.translateNumbers
                                  ? "${getHijriMonthName(dateTimeToHijri(currentWeek.first))} ${"${dateTimeToHijri(currentWeek.first).hYear}".convertNumbers(widget.languageCode)}"
                                  : "${getHijriMonthName(dateTimeToHijri(currentWeek.first))} ${dateTimeToHijri(currentWeek.first).hYear}")
                          : DateFormat(widget.monthFormat).format(
                              currentWeek.first,
                            ),
                      style: (widget.monthTextStyle ??
                              theme.textTheme.titleMedium!)
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.monthColor ?? theme.primaryColor,
                      ),
                    ),
                    widget.showNavigationButtons == true
                        ? GestureDetector(
                            onTap: _isNextDisabled()
                                ? null
                                : () {
                                    _onNextClick();
                                  },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Next",
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: _isNextDisabled()
                                        ? (widget.inactiveNavigatorColor ??
                                            Colors.grey)
                                        : theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 17,
                                  color: _isNextDisabled()
                                      ? (widget.inactiveNavigatorColor ??
                                          Colors.grey)
                                      : theme.primaryColor,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              if (widget.showTopNavbar) const SizedBox(height: 12),
              CarouselSlider(
                // carouselController: carouselController,
                controller: carouselController,
                items: [
                  if (listOfWeeks.isNotEmpty)
                    for (int ind = 0; ind < listOfWeeks.length; ind++)
                      SizedBox(
                        // height: boxHeight,
                        width: double.infinity,
                        // color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            for (int weekIndex = 0;
                                weekIndex < listOfWeeks[ind].length;
                                weekIndex++)
                              Builder(builder: (_) {
                                DateTime currentDate =
                                    listOfWeeks[ind][weekIndex];
                                return Expanded(
                                  child: GestureDetector(
                                    // onTap: () {
                                    //   _onDateSelect(currentDate);
                                    // },
                                    // TODO: disabled
                                    onTap: _isReachMaximum(currentDate) &&
                                            _isReachMinimum(currentDate)
                                        ? () {
                                            _onDateSelect(
                                              listOfWeeks[ind][weekIndex],
                                            );
                                          }
                                        : null,
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(
                                          horizontal:
                                              widget.itemMarginHorizontal ?? 2),
                                      decoration: BoxDecoration(
                                        borderRadius: widget.borderRadius,
                                        // color: DateFormat('dd-MM-yyyy').format(
                                        //             listOfWeeks[ind]
                                        //                 [weekIndex]) ==
                                        //         DateFormat('dd-MM-yyyy')
                                        //             .format(selectedDate)
                                        //     ? widget.activeBackgroundColor ??
                                        //         theme.primaryColor
                                        //     : widget.inactiveBackgroundColor ??
                                        //         theme.primaryColor
                                        //             .withValues(alpha: .2),
                                        // TODO: disabled
                                        color: DateFormat('dd-MM-yyyy')
                                                    .format(currentDate) ==
                                                DateFormat('dd-MM-yyyy')
                                                    .format(selectedDate)
                                            ? widget.activeBackgroundColor ??
                                                theme.primaryColor
                                            : _isReachMaximum(currentDate) &&
                                                    _isReachMinimum(currentDate)
                                                ? widget.inactiveBackgroundColor ??
                                                    theme.primaryColor
                                                        .withValues(alpha: .2)
                                                : widget.disabledBackgroundColor ??
                                                    Colors.grey,
                                        border: Border.all(
                                          color: widget.itemBorderColor ??
                                              theme.scaffoldBackgroundColor,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            // "$weekIndex: ${listOfWeeks[ind][weekIndex] == DateTime.now()}",
                                            widget.translateNumbers
                                                ? "${dateTimeToHijri(currentDate).hDay}"
                                                    .convertNumbers(
                                                        widget.languageCode)
                                                : "${dateTimeToHijri(currentDate).hDay}",
                                            textAlign: TextAlign.center,
                                            style: (widget.dayTextStyle ??
                                                    theme.textTheme.titleLarge!)
                                                .copyWith(
                                              // color: DateFormat('dd-MM-yyyy')
                                              //             .format(listOfWeeks[
                                              //                     ind]
                                              //                 [weekIndex]) ==
                                              //         DateFormat('dd-MM-yyyy')
                                              //             .format(selectedDate)
                                              //     ? widget.activeTextColor ??
                                              //         Colors.white
                                              //     : widget.inactiveTextColor ??
                                              //         Colors.white
                                              //             .withValues(alpha: .2),
                                              // TODO: disabled
                                              color: DateFormat('dd-MM-yyyy')
                                                          .format(
                                                              currentDate) ==
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(selectedDate)
                                                  ? widget.activeTextColor ??
                                                      Colors.white
                                                  : _isReachMaximum(
                                                              currentDate) &&
                                                          _isReachMinimum(
                                                              currentDate)
                                                      ? widget.inactiveTextColor ??
                                                          Colors.white
                                                              .withValues(
                                                                  alpha: .2)
                                                      : widget.disabledTextColor ??
                                                          Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            getHijriDayName(
                                                listOfWeeks[ind][weekIndex]),
                                            textAlign: TextAlign.center,
                                            style: (widget.dayNameTextStyle ??
                                                    theme.textTheme.bodyLarge!)
                                                .copyWith(
                                              // color: DateFormat('dd-MM-yyyy')
                                              //             .format(listOfWeeks[
                                              //                     ind]
                                              //                 [weekIndex]) ==
                                              //         DateFormat('dd-MM-yyyy')
                                              //             .format(selectedDate)
                                              //     ? widget.activeTextColor ??
                                              //         Colors.white
                                              //     : widget.inactiveTextColor ??
                                              //         Colors.white
                                              //             .withValues(alpha: .2),
                                              // TODO: disabled
                                              color: DateFormat('dd-MM-yyyy')
                                                          .format(
                                                              currentDate) ==
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(selectedDate)
                                                  ? widget.activeTextColor ??
                                                      Colors.white
                                                  : _isReachMaximum(
                                                              currentDate) &&
                                                          _isReachMinimum(
                                                              currentDate)
                                                      ? widget.inactiveTextColor ??
                                                          Colors.white
                                                              .withValues(
                                                                  alpha: .2)
                                                      : widget.disabledTextColor ??
                                                          Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                ],
                options: CarouselOptions(
                  initialPage: _initialPage,
                  scrollPhysics:
                      widget.scrollPhysics ?? const ClampingScrollPhysics(),
                  height: widget.carouselHeight ?? 75,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  reverse: true,
                  onPageChanged: (index, reason) {
                    onWeekChange(index);
                  },
                ),
              ),
            ],
          );
  }
}

class HorizontalWeekCalenderController {
  final ValueNotifier<int> _stateChangerPre = ValueNotifier<int>(0);
  final ValueNotifier<int> _stateChangerNex = ValueNotifier<int>(0);

  void jumpPre() {
    _stateChangerPre.value = _stateChangerPre.value + 1;
  }

  void jumpNext() {
    _stateChangerNex.value = _stateChangerNex.value + 1;
  }
}
