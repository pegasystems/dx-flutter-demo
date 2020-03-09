// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class WrappedTextField extends StatelessWidget {
  final String label;
  final value;

  const WrappedTextField(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final textValue = value == null ? '' : value.toString();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.body1.copyWith(color: Color(0xFF626475))),
          Text(textValue, style: Theme.of(context).textTheme.subhead)
        ]
      )
    );
  }
}
