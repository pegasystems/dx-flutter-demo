// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

//import 'package:flutter/material.dart';
//import 'package:flutter_app/widgets/abstract_widgets.dart';
//import 'package:flutter_app/widgets/inputs/date_range_picker.dart';
//
//class InputDateRange extends AbstractInputDateRange {
//  InputDateRange(String label, DateTime dateFrom, DateTime dateTo,
//      Function(DateTime dateFrom, DateTime dateTo) onchange)
//      : super(label, dateFrom, dateTo, onchange);
//
//  @override
//  Widget build(BuildContext context) {
//    return InputDecorator(
//        decoration: InputDecoration(
//          border: InputBorder.none,
//          labelText: label,
//        ),
//        child: DateRangePicker(
//            selectedDateFrom: dateFrom,
//            selectedDateTo: dateTo,
//            selectDate: onchange));
//  }
//}
