// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/utils/dx_store.dart';
import 'package:dx_flutter_demo/widgets/other/loading_overlay.dart';

final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

bool _showingOverlay = false;

void attachListener() {
  dxStore.onChange.listen((dxState) {
    bool fetchingPage = dxState['fetchingData'];
    if (_showingOverlay != fetchingPage) {
      if (fetchingPage == true) {
        key.currentState.push(LoadingOverlay());
      } else {
        key.currentState.pop();
      }
      _showingOverlay = fetchingPage;
    }
  });
}
