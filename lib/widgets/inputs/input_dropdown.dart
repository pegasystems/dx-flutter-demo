// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

//library input_dropdown_widget;
//
//import 'package:flutter/widgets.dart';
//import 'package:flutter/material.dart';
//
//class InputDropdown extends StatelessWidget {
//  const InputDropdown({
//    Key key,
//    this.child,
//    this.labelText,
//    this.valueText,
//    this.onPressed,
//    this.icon,
//  }) : super(key: key);
//
//  final String labelText;
//  final String valueText;
//  final VoidCallback onPressed;
//  final Widget child;
//  final Icon icon;
//
//  @override
//  Widget build(BuildContext context) {
//    return InkWell(
//      onTap: onPressed,
//      child: InputDecorator(
//        decoration: InputDecoration(
//          labelText: labelText,
//        ),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            Text(valueText),
//            icon ?? Icon(Icons.arrow_drop_down)
//          ],
//        ),
//      ),
//    );
//  }
//}
