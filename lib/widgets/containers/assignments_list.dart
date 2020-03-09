// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/utils/dx_store.dart';

class AssignmentsList extends StatelessWidget {
  final List assignments;
  final String keyFieldName;
  final String labelFieldName;
  final String idFieldName;
  final String priorityFieldName;
  final String statusFieldName;

  const AssignmentsList(
      this.assignments,
      this.keyFieldName,
      this.labelFieldName,
      this.idFieldName,
      this.priorityFieldName,
      this.statusFieldName);

  @override
  Widget build(BuildContext context) {
    dxStore.dispatch(ToggleCustomButtonsVisibility({
      DxContextButtonAction.filter: true,
      DxContextButtonAction.search: true
    }));
    return ListView.builder(
        shrinkWrap: true,
        itemCount: assignments.length,
        itemBuilder: (BuildContext context, int index) {
          final assignment = assignments[index];
          final String key = assignment[keyFieldName];
          final String id = assignment[idFieldName].split(' ').last;
          final String label = assignment[labelFieldName];
          final String priority = assignment[priorityFieldName];
          final String status = assignment[statusFieldName];
          return Dismissible(
              key: Key(key),
              background: Container(
                  color: Colors.orangeAccent,
                  child: Row(children: [
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(Icons.delete))),
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.delete))),
                    ),
                  ])),
              onDismissed: (direction) => {},
              child: ListTile(
                  onTap: () => dxStore.dispatch(OpenAssignment(key)),
                  title: Row(
                    children: [
                      Text(label),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(id, style: TextStyle(color: Color(0xFF626475)))
                      )
                    ]
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        color: Color(0xFFDAF2E3),
                        child: Text(status.toUpperCase(), style: TextStyle(color: Color(0xFF006624)))
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(priority + ' Priority'),
                      )
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward)));
        });
  }
}
