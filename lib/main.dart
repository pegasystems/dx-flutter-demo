// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:dx_flutter_demo/utils/dx_interpreter.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/widgets/factory.dart';
import 'utils/dx_store.dart';
import 'utils/app_navigator.dart' as navigator;
import 'widgets/other/splash_loading.dart';

void main() {
  runApp(StoreProvider(
      store: dxStore,
      child: MaterialApp(
          title: 'DxFlutter',
          theme: ThemeData(
            primaryColor: Color(0xFF383838),
            accentColor: Color(0xFF919191),
            unselectedWidgetColor: Color(0xFF919191)
          ),
          navigatorKey: navigator.key,
          home: StoreConnector<UnmodifiableMapView<String, dynamic>, UnmodifiableMapView<String, dynamic>>(
              converter: (dxStore) => getCurrentPortal(),
              distinct: true,
              builder: (context, portal) {
//                if (portal != null) {
//                  final node = getRootNode(portal);
//                  return getWidget(node, context, getUpdatedPathContext('', node),
//                      dxContext: DxContext.currentPortal);
//                }
                return SplashLoading();
              }))));

  navigator.attachListener();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    dxStore.dispatch(FetchPortal('ConstellationPortal'));
  });
}
