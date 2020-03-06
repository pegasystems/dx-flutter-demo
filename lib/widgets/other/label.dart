// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

//import 'package:flutter_app/widgets/abstract_widgets.dart';
//import 'package:flutter/widgets.dart';
//import 'package:flutter/material.dart';
//
//class Label extends AbstractLabel {
//  Label(String text, String format) : super(text, format);
//
//  @override
//  Widget build(BuildContext context) {
//    switch (format) {
//      case 'Heading 1':
//        return Container(
//            padding: EdgeInsets.all(10),
//            child: Text(text ?? '', style: TextStyle(fontSize: 20)));
//      case 'Heading 2':
//        return Container(
//            padding: EdgeInsets.all(10),
//            child: Text(text ?? '', style: TextStyle(fontSize: 18)));
//      case 'Standard (label)':
//        return Container(padding: EdgeInsets.all(5), child: Text(text ?? ''));
//      case 'Badge text':
//        return Container(
//            padding: EdgeInsets.all(5),
//            child: Text(text ?? '',
//                style: TextStyle(fontWeight: FontWeight.bold)));
//      case 'Secondary information':
//        return Container(
//            padding: EdgeInsets.all(5),
//            child: Text(text ?? '', style: TextStyle(fontSize: 12)));
//    }
//    return Text(text ?? '');
//  }
//}
