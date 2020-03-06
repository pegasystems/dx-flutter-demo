// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  final String label;
  final value;
  final Function onChange;
  final bool required;

  const InputText(this.label, this.value, this.required, this.onChange);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
        child: TextFormField(
          onChanged: onChange,
          initialValue: value,
          decoration: InputDecoration(hintText: label),
          validator: (value) {
            if (required == true && value.isEmpty) {
              return 'field required';
            }
            return null;
          },
        ));
  }
}
