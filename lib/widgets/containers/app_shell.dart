// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/utils/dx_interpreter.dart';
import 'package:dx_flutter_demo/utils/dx_store.dart';
import 'package:dx_flutter_demo/utils/pega_icons.dart';
import 'package:dx_flutter_demo/widgets/factory.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AppShell extends StatelessWidget {
  final String appName;
  final List pages;
  final List caseTypes;

  const AppShell(this.appName, this.pages, this.caseTypes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: Text(appName)),
        floatingActionButton: StoreConnector<Map, Map>(
            converter: (dxStore) => getContextButtonsVisibility(dxStore.state),
            distinct: true,
            builder: (context, Map contextButtonsVisibility) {
              if (contextButtonsVisibility[DxContextButtonAction.submit.toString()] ==
                  true) {
                return FloatingActionButton(
                  onPressed: () =>
                    contextButtonActions.add(DxContextButtonAction.submit),
                  child: Icon(getIconData('pi-check')),
                  backgroundColor: Colors.green,
                );
              }
              if (contextButtonsVisibility[DxContextButtonAction.filter.toString()] ==
                  true) {
                return FloatingActionButton(
                  onPressed: () {
                    // Add your onPressed code here!
                  },
                  child: Icon(getIconData('pi-filter')),
                  backgroundColor: Colors.green,
                );
              }
              return Container(width: 0, height: 0);
            }),
        body: StoreConnector<Map, dynamic>(
            converter: (dxStore) => getCurrentPage(),
            distinct: true,
            builder: (context, node) => getWidget(getRootNode(node), context)),
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            child: Text('Menu'),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
          ),
          ExpansionTile(
              leading: Icon(Icons.add),
              title: Text('Create...'),
              children: caseTypes
                  .map((caseType) => ListTile(
                      // leading: Icon(Icons.create),
                      title: Text(caseType['pyLabel']),
                      onTap: () => {}))
                  .toList()
              //),
              ),
          ...pages
              .map((page) => ListTile(
                  leading: Icon(getIconData(page['pxPageViewIcon'])),
                  title: Text(page['pyLabel']),
                  onTap: () {
                    Navigator.pop(context);
                    dxStore.dispatch(
                        FetchPage(page['pyRuleName'], page['pyClassName']));
                  }))
              .toList()
        ])));
  }
}
