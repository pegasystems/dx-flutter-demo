// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class WrappedTextField extends StatelessWidget {
  final String label;
  final value;

  const WrappedTextField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final textValue = value == null ? '' : value.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(10, 10, 6, 10),
            decoration: ShapeDecoration(
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(10), right: Radius.zero))),
            child: Text(label, style: TextStyle(color: Colors.white))),
        Container(
            padding: EdgeInsets.fromLTRB(6, 9, 9, 9),
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(10), left: Radius.zero)),
            child: textValue.isNotEmpty
                ? Text(textValue)
                : Text(label,
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic))),
      ],
    );
  }
}
