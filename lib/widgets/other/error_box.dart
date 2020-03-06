// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  final String message;

  const ErrorBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.red, width: 1)),
        child: Text(message, style: TextStyle(color: Colors.red)));
  }
}
