import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:horizontal_week_calendar/convert_number_extension.dart';
import 'package:horizontal_week_calendar/horizontal_week_calendar.dart';
// import 'package:horizontal_week_calendar/horizontal_week_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Packages Test',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HorizontalWeekCalendarPackage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HorizontalWeekCalendarPackage extends StatefulWidget {
  const HorizontalWeekCalendarPackage({super.key});

  @override
  State<HorizontalWeekCalendarPackage> createState() =>
      _HorizontalWeekCalendarPackageState();
}

class _HorizontalWeekCalendarPackageState
    extends State<HorizontalWeekCalendarPackage> {
  var selectedDate = DateTime.now();
  bool translateNumbers = true; // خاصية ترجمة الأرقام
  String languageCode = 'ar'; // رمز اللغة
  bool useHijriDates = false; // خاصية استخدام التقويم الهجري

  // أمثلة على الأسماء المخصصة
  List<String> customDayNames = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت'
  ];

  List<String> customMonthNames = [
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

  // Helper function to get Hijri month name
  String getHijriMonthName(HijriCalendar hijriDate) {
    return customMonthNames[hijriDate.hMonth - 1];
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Horizontal Week Calendar",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              HorizontalWeekCalendar(
                minDate: DateTime.now().subtract(const Duration(days: 7)),
                maxDate: DateTime.now().add(const Duration(days: 7)),
                initialDate: DateTime.now(),
                onDateChange: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
                showTopNavbar: true,
                monthFormat: useHijriDates
                    ? null
                    : "MMMM yyyy", // استخدام monthFormat فقط للميلادي
                showNavigationButtons: true,
                weekStartFrom: WeekStartFrom.monday,
                borderRadius: BorderRadius.circular(7),
                activeBackgroundColor: Colors.deepPurple,
                activeTextColor: Colors.white,
                inactiveBackgroundColor: Colors.deepPurple.withOpacity(.3),
                inactiveTextColor: Colors.white,
                disabledTextColor: Colors.grey,
                disabledBackgroundColor: Colors.grey.withOpacity(.3),
                activeNavigatorColor: Colors.deepPurple,
                inactiveNavigatorColor: Colors.grey,
                monthColor: Colors.deepPurple,
                onWeekChange: (List<DateTime> dates) {},
                scrollPhysics: const BouncingScrollPhysics(),
                // الخاصيات الجديدة للنظام الهجين
                useHijriDates: useHijriDates,
                hijriMinDate: useHijriDates
                    ? HijriCalendar.fromDate(
                        DateTime.now().subtract(const Duration(days: 7)))
                    : null,
                hijriMaxDate: useHijriDates
                    ? HijriCalendar.fromDate(
                        DateTime.now().add(const Duration(days: 7)))
                    : null,
                hijriInitialDate: useHijriDates
                    ? HijriCalendar.fromDate(DateTime.now())
                    : null,
                // خاصيات الترجمة والتخصيص
                translateNumbers: translateNumbers,
                languageCode: languageCode,
                customDayNames: customDayNames,
                customMonthNames: customMonthNames,
                // خاصيات التصميم
                dayTextStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                dayNameTextStyle: const TextStyle(fontSize: 12),
                monthTextStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // عناصر التحكم في الترجمة ونوع التقويم
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "نوع التقويم:",
                            style: theme.textTheme.titleMedium,
                          ),
                          Switch(
                            value: useHijriDates,
                            onChanged: (value) {
                              setState(() {
                                useHijriDates = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Text(
                        useHijriDates ? "التقويم الهجري" : "التقويم الميلادي",
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ترجمة الأرقام:",
                            style: theme.textTheme.titleMedium,
                          ),
                          Switch(
                            value: translateNumbers,
                            onChanged: (value) {
                              setState(() {
                                translateNumbers = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "اللغة:",
                            style: theme.textTheme.titleMedium,
                          ),
                          DropdownButton<String>(
                            value: languageCode,
                            items: const [
                              DropdownMenuItem(
                                  value: 'ar', child: Text('عربي')),
                              DropdownMenuItem(
                                  value: 'en', child: Text('English')),
                              DropdownMenuItem(
                                  value: 'bn', child: Text('বাংলা')),
                              DropdownMenuItem(
                                  value: 'ur', child: Text('اردو')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  languageCode = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "التاريخ المحدد",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (!useHijriDates) ...[
                      Text(
                        "الميلادي: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Builder(builder: (context) {
                        var hijriDate = HijriCalendar.fromDate(selectedDate);
                        String hijriDay = translateNumbers
                            ? "${hijriDate.hDay}".convertNumbers(languageCode)
                            : "${hijriDate.hDay}";
                        String hijriYear = translateNumbers
                            ? "${hijriDate.hYear}".convertNumbers(languageCode)
                            : "${hijriDate.hYear}";
                        return Text(
                          "الهجري: $hijriDay ${getHijriMonthName(hijriDate)} $hijriYear",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ] else ...[
                      Builder(builder: (context) {
                        var hijriDate = HijriCalendar.fromDate(selectedDate);
                        String hijriDay = translateNumbers
                            ? "${hijriDate.hDay}".convertNumbers(languageCode)
                            : "${hijriDate.hDay}";
                        String hijriYear = translateNumbers
                            ? "${hijriDate.hYear}".convertNumbers(languageCode)
                            : "${hijriDate.hYear}";
                        return Text(
                          "الهجري: $hijriDay ${getHijriMonthName(hijriDate)} $hijriYear",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                      const SizedBox(height: 5),
                      Text(
                        "الميلادي: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
