// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/utils/pega_icons.dart';
import 'package:dx_flutter_demo/widgets/factory.dart';

class CaseView extends StatelessWidget {
  final String label;
  final String id;
  final String iconName;
  final List<Map<String, dynamic>> children;

  const CaseView(this.label, this.id, this.iconName, this.children);

  @override
  Widget build(BuildContext context) {
    Widget header = Card(
        color: Theme.of(context).accentColor,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 5, 10, 5),
                child: Icon(getIconData(iconName)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).accentTextTheme.title),
                  Text(id, style: Theme.of(context).accentTextTheme.subtitle)
                ],
              )
            ],
          ),
        ));
    return Column(children: [header, ...getWidgets(children, context)]);
  }
}
