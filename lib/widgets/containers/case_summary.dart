// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/widgets/other/text_field.dart';

class CaseSummary extends StatelessWidget {
  final String status;
  final List primaryFields;
  final List secondaryFields;

  const CaseSummary(this.status, this.primaryFields, this.secondaryFields);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey.shade100,
        padding: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 15,
                      runSpacing: 10,
                      children: [
                        PhysicalShape(
                            elevation: 10.0,
                            color: Color(0xFFDAF2E3),
                            clipper: ShapeBorderClipper(
                                shape: ContinuousRectangleBorder()),
                            child: Container(
                                padding: EdgeInsets.fromLTRB(15, 12, 12, 10),
                                child: Text(status.toUpperCase(),
                                    style: TextStyle(color: Color(0xFF006624))))),
                        ...primaryFields
                            .map(
                              (field) => PhysicalShape(
                                  elevation: 10.0,
                                  color: Colors.white,
                                  clipBehavior: Clip.antiAlias,
                                  clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.blue, width: 10),
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                  child: Container(
                                      child: Column(children: [
                                    Container(
                                        color: Color(0xFF295ED9),
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          field['name'],
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    Container(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          field['value'] != null
                                              ? field['value'].toString()
                                              : '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead,
                                        ))
                                  ]))),
                            )
                            .toList()
                      ]),
                )),
            Expanded(
              flex: 6,
              child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 15.0,
                  runSpacing: 10.0,
                  children: secondaryFields
                      .map((field) =>
                          WrappedTextField(field['name'], field['value']))
                      .toList()),
            ),
          ],
        ));
  }
}
