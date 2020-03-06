// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

//library date_picker_widget;
//
//import 'package:flutter/widgets.dart';
//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:flutter_app/widgets/inputs/input_dropdown.dart';
//
//class DatePicker extends StatelessWidget {
//  const DatePicker({
//    Key key,
//    this.labelText,
//    this.selectedDate,
//    this.selectDate,
//  }) : super(key: key);
//
//  final String labelText;
//  final DateTime selectedDate;
//  final ValueChanged<DateTime> selectDate;
//
//  Future<void> _selectDate(BuildContext context) async {
//    final DateTime picked = await showDatePicker(
//        context: context,
//        initialDate: selectedDate,
//        firstDate: DateTime.utc(1900, 1, 1),
//        lastDate: DateTime.now());
//    if (picked != null && picked != selectedDate) selectDate(picked);
//  }
//
//  @override
//  Widget build(BuildContext context) => InputDropdown(
//      labelText: labelText,
//      valueText: DateFormat.yMMMd().format(selectedDate),
//      onPressed: () {
//        _selectDate(context);
//      },
//      icon: Icon(Icons.calendar_today));
//}
