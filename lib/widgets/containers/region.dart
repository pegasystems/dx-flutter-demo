// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class Region extends StatelessWidget {
  final String name;
  final List<Widget> children;

  const Region(this.name, this.children);

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: children);
  }
}

