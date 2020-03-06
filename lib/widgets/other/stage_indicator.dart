// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class CaseStageIndicator extends StatelessWidget {
  final List stages;

  const CaseStageIndicator(this.stages);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stages.map((stage) {
          final String stageName = stage['pyStageName'];
          final String status = stage['pyStageStatus'];
          final Color color = status == 'Active'
              ? Colors.lightBlueAccent
              : status == 'Past' ? Colors.lightGreen.shade700 : Colors.grey;

          return Expanded(
              child: Container(
                  padding: EdgeInsets.only(left: 8, right: 5),
                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(minHeight: 40),
                  decoration: ShapeDecoration(
                      color: color,
                      shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.zero,
                              right: Radius.elliptical(15, 30)))),
                  child: Text(
                    stageName,
                    style: TextStyle(color: Colors.white),
                  )));
        }).toList(),
      ),
    );
  }
}
