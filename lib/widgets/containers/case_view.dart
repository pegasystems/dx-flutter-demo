// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/utils/pega_icons.dart';

class CaseView extends StatelessWidget {
  final String label;
  final String id;
  final String iconName;
  final List<Widget> children;

  const CaseView(this.label, this.id, this.iconName, this.children);

  @override
  Widget build(BuildContext context) {
    Widget header = Container(
      color: Color(0xFF295ED9),
      padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: Color(0xFF113DA6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))
              )
            ),
            padding: EdgeInsets.all(10),
            child: Icon(getIconData(iconName), color: Colors.white,),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: Theme.of(context).accentTextTheme.subtitle),
                Text(label, style: Theme.of(context).accentTextTheme.title),
              ],
            )
          )
        ],
      ),
    );
    return ListView(children: [header, ...children]);
  }
}
