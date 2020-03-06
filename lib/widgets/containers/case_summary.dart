// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/utils/pega_icons.dart';
import 'package:dx_flutter_demo/widgets/other/text_field.dart';

class CaseSummary extends StatelessWidget {
  final String status;
  final List primaryFields;
  final List secondaryFields;

  const CaseSummary(this.status, this.primaryFields, this.secondaryFields);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Wrap(spacing: 8.0, runSpacing: 4.0, children: [
                Chip(
                    avatar: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        child: Icon(getIconData('pi-clipboard-medical'))),
                    backgroundColor: Theme.of(context).accentColor,
                    label: Text(status, style: TextStyle(color: Colors.white)),
                    labelPadding: EdgeInsets.fromLTRB(10, 3, 10, 3)),
                ...primaryFields
                    .map((field) =>
                        WrappedTextField(field['name'], field['value']))
                    .toList()
              ]),
            ),
            Expanded(
              flex: 7,
              child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: secondaryFields
                      .map((field) =>
                          WrappedTextField(field['name'], field['value']))
                      .toList()),
            ),
          ],
        ));
  }
}
