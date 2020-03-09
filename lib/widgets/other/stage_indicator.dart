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
      color: Color(0xFFE8EAEF),
      constraints: BoxConstraints(
        minHeight: 70,
        maxHeight: 80
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stages
            .asMap()
            .map((index, stage) {
              final String stageName = stage['pyStageName'];
              final String status = stage['pyStageStatus'];
              final Color color = status == 'Active'
                  ? Colors.white
                  : status == 'Past'
                      ? Color(0xFFDAF2E3)
                      : Colors.grey.shade100;
              final textStyle = status == 'Active'
                  ? TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                  : TextStyle(color: Colors.grey);

              return MapEntry(
                  index,
                  Expanded(
                      child: PhysicalShape(
                          elevation: 10.0,
                          color: color,
                          clipper: _StageClipper(
                              index == 0, index == stages.length - 1),
                          child: Container(
                              padding: EdgeInsets.fromLTRB(15, 12, 12, 10),
                              alignment: Alignment.centerLeft,
                              constraints: BoxConstraints(minHeight: 35),
                              child: Text(stageName, style: textStyle)))));
            })
            .values
            .toList(),
      ),
    );
  }
}

class _StageClipper extends CustomClipper<Path> {
  final bool isFirst;
  final bool isLast;

  _StageClipper(this.isFirst, this.isLast);
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    if (isFirst == false) {
      path.lineTo(10, size.height / 2);
    }
    path.lineTo(0, size.height);
    if (isLast) {
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    } else {
      path.lineTo(size.width - 10, size.height);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - 10, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
