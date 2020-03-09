// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputInteger extends StatelessWidget {
  final String label;
  final value;
  final Function onChange;
  final bool required;

  const InputInteger(this.label, this.value, this.required, this.onChange);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType:
            TextInputType.numberWithOptions(signed: false, decimal: false),
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        onChanged: onChange,
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (required == true && value.isEmpty) {
            return 'field required';
          }
          return null;
        });
  }
}
