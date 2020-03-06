// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

//library date_picker_widget;
//
//import 'package:flutter/widgets.dart';
//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:flutter_app/widgets/inputs/input_dropdown.dart';
//import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
//
//class DateRangePicker extends StatelessWidget {
//  const DateRangePicker({
//    Key key,
//    this.labelText,
//    this.selectedDateFrom,
//    this.selectedDateTo,
//    this.selectDate,
//  }) : super(key: key);
//
//  final String labelText;
//  final DateTime selectedDateFrom;
//  final DateTime selectedDateTo;
//  final Function(DateTime dateFrom, DateTime dateTo) selectDate;
//
//  Future<void> _selectDate(BuildContext context) async {
//    final List<DateTime> picked = await DateRagePicker.showDatePicker(
//      context: context,
//      initialFirstDate: selectedDateFrom,
//      initialLastDate: selectedDateTo,
//      firstDate: new DateTime.now(),
//      lastDate: (new DateTime.now()).add(new Duration(days: 365)),
//    );
//    if (picked != null && picked.length == 2) {
//      selectDate(picked[0], picked[1]);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) => InputDropdown(
//      labelText: labelText,
//      valueText: DateFormat.yMMMd().format(selectedDateFrom) +
//          ' - ' +
//          DateFormat.yMMMd().format(selectedDateTo),
//      onPressed: () {
//        _selectDate(context);
//      },
//      icon: Icon(Icons.calendar_today));
//}
