// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../factory.dart';

class Region extends StatelessWidget {
  final String name;
  final List<Map<String, dynamic>> children;

  const Region(this.name, this.children);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: getRegionSizeRatio(name),
        child: Card(
            child: Column(
          children: getWidgets(children, context),
        )));
  }
}

int getRegionSizeRatio(String regionName) {
  switch (regionName) {
    case 'Main':
      return 10;
    case 'Info':
      return 2;
    case 'Left':
    case 'B':
    case 'Utilities':
      return 0;
    default:
      return 1;
  }
}
