// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../factory.dart';

class Page extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> children;

  const Page(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = getWidgets(children, context);
    if (title != null && title.isNotEmpty) {
      widgets = [
        Container(
          padding: EdgeInsets.fromLTRB(5, 12, 5, 5),
          child: Text(title, style: Theme.of(context).textTheme.headline),
        ),
        Divider(),
        ...widgets
      ];
    }
    return Column(children: widgets);
  }
}
