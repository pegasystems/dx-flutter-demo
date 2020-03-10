// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:dx_flutter_demo/utils/dx_interpreter.dart';
import 'package:dx_flutter_demo/utils/dx_store.dart';
import 'package:dx_flutter_demo/widgets/inputs/input_integer.dart';
import 'package:dx_flutter_demo/widgets/other/stage_indicator.dart';
import 'package:dx_flutter_demo/widgets/inputs/input_select.dart';
import 'package:dx_flutter_demo/widgets/inputs/input_text.dart';
import 'package:dx_flutter_demo/widgets/containers/assignments_list.dart';
import 'package:dx_flutter_demo/widgets/containers/case_summary.dart';
import 'package:dx_flutter_demo/widgets/containers/case_view.dart';
import 'package:dx_flutter_demo/utils/pega_icons.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'containers/assignment_form.dart';
import 'containers/page.dart';
import 'containers/app_shell.dart';
import 'containers/region.dart';
import 'other/error_box.dart';

List<Widget> getWidgets(List<Map<String, dynamic>> nodes, BuildContext context,
    String pathContext, DxContext dxContext) {
  if (nodes != null) {
    return nodes
        .map((Map node) => getWidget(node, context, getUpdatedPathContext(pathContext, node),
                dxContext: dxContext))
        .where((widget) => widget != null)
        .toList();
  }
  return null;
}

List<Widget> getChildWidgets(UnmodifiableMapView<String, dynamic> node,
    BuildContext context, String pathContext, DxContext dxContext) {
  final List<Map<String, dynamic>> children = getChildNodes(node);
  return getWidgets(children, context, pathContext, dxContext);
}

// in some cases the given node won't have a representation in the application's layout
// this method will skip one node to continue rendering its children
Widget skipNode(UnmodifiableMapView<String, dynamic> node, BuildContext context,
    String pathContext, DxContext dxContext) {
  final List<UnmodifiableMapView<String, dynamic>> children =
      getChildNodes(node);
  if (children.length > 1) {
    return Column(
        children: getWidgets(children, context,
            getUpdatedPathContext(pathContext, node), dxContext));
  }
  return getWidget(
      children.first, context, getUpdatedPathContext(pathContext, node),
      dxContext: dxContext);
}

/// method responsible for spitting out flutter widgets based on the current ui metadata node and context data
Widget getWidget(UnmodifiableMapView<String, dynamic> node,
    BuildContext context, String pathContext,
    {DxContext dxContext = DxContext.currentPage}) {
  // check if node has a reference to another arbitrary leaf in the ui metadata tree
  if (hasReference(node)) {
    node = getReferencedNode(node, dxContext, pathContext);
  }

  final String nodeType = node != null ? node['type'] : '';
  // based on the node's type, the appropriate widget is chosen
  switch (nodeType.toLowerCase()) {
    case 'table':
      final List items = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'referenceList']),
          dxContext);
      return AssignmentsList(items, 'pzInsKey', 'pyLabel', 'pxRefObjectInsName',
          'pxUrgencyAssign', 'pyAssignmentStatus');
    case 'todo':
      final List assignments = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'assignmentsList']),
          dxContext);
      return AssignmentsList(assignments.take(3).toList(), 'pzInsKey',
          'pyLabel', 'pxRefObjectKey', 'pxUrgencyAssign', 'pyAssignmentStatus');
    case 'region':
      final String name = node['name'];
      return Region(
          name, getChildWidgets(node, context, pathContext, dxContext));
    case 'page':
      String title = getDataPropertyRecursive(node, ['config', 'title']);
      if (title != null && title.isNotEmpty) {
        final String operator = resolvePropertyValue(
            getDataPropertyRecursive(node, ['config', 'operator']),
            dxContext,
            pathContext);
        if (operator != null && operator.isNotEmpty) {
          title += ', $operator';
        }
      }
      return Page(
          title, getChildWidgets(node, context, pathContext, dxContext));
    case 'appshell':
      final String appName = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'appName']),
          dxContext,
          pathContext);
      final List pages = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'pages']), dxContext);
      final List caseTypes = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'caseTypes']), dxContext);
      final List<Map<String, dynamic>> children = getChildNodes(node);
      final Map<String, dynamic> currentPage = children.first;
      // dx store's current page is set only if not yet initialized
      // subsequent "InitCurrentPage" actions (eg. during hot-reloading) won't take effect
      dxStore.dispatch(InitCurrentPage(currentPage));
      return AppShell(appName, pages, caseTypes);
    case 'caseview':
      final String label = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'heading']),
          dxContext,
          pathContext);
      final String id = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'id']),
          dxContext,
          pathContext);
      final String iconName =
          getDataPropertyRecursive(node, ['config', 'icon']);
      return CaseView(label, id, iconName,
          getChildWidgets(node, context, pathContext, dxContext));
    case 'casesummary':
      final List primaryFields = resolvePropertyValues(
          getDataPropertyRecursive(node, ['config', 'primaryFields']),
          'value',
          dxContext,
          pathContext);
      final List secondaryFields = resolvePropertyValues(
          getDataPropertyRecursive(node, ['config', 'secondaryFields']),
          'value',
          dxContext,
          pathContext);
      final String status = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'status']),
          dxContext,
          pathContext);
      return CaseSummary(status, primaryFields, secondaryFields);
    case 'stages':
      return StoreConnector<UnmodifiableMapView<String, dynamic>,
              UnmodifiableMapView<String, dynamic>>(
          converter: (store) => getCurrentPageData(),
          distinct: true,
          builder: (context, value) {
            final List stages = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'stages']),
                dxContext,
                pathContext);
            return CaseStageIndicator(stages);
          });
    case 'textinput':
      return StoreConnector<UnmodifiableMapView<String, dynamic>,
              UnmodifiableMapView<String, dynamic>>(
          converter: (store) => getCurrentFormData(),
          distinct: true,
          builder: (context, value) {
            final String label = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'label']),
                dxContext,
                pathContext);
            final String propertyValueRef =
                getDataPropertyRecursive(node, ['config', 'value']);
            final value = resolveFormPropertyValue(
                propertyValueRef, dxContext, pathContext);
            final String required =
                getDataPropertyRecursive(node, ['config', 'required']);
            return InputText(
                label,
                value,
                required == 'true',
                (value) => dxStore.dispatch(UpdateCurrentFormData(
                    propertyValueRef, pathContext, value)));
          });
    case 'pxdropdown':
    case 'dropdown':
      return StoreConnector<UnmodifiableMapView<String, dynamic>,
              UnmodifiableMapView<String, dynamic>>(
          converter: (store) => getCurrentFormData(),
          distinct: true,
          builder: (context, value) {
            final List options = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'datasource']),
                dxContext,
                pathContext);
            final String label = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'label']),
                dxContext,
                pathContext);
            final String propertyValueRef =
                getDataPropertyRecursive(node, ['config', 'value']);
            final value = resolveFormPropertyValue(
                propertyValueRef, dxContext, pathContext);
            final String required =
                getDataPropertyRecursive(node, ['config', 'required']);
            return InputSelect(
                label,
                value,
                required == 'true',
                options,
                (value) => dxStore.dispatch(UpdateCurrentFormData(
                    propertyValueRef, pathContext, value)));
          });
    case 'pxinteger':
    case 'integer':
      return StoreConnector<UnmodifiableMapView<String, dynamic>,
              UnmodifiableMapView<String, dynamic>>(
          converter: (store) => getCurrentFormData(),
          distinct: true,
          builder: (context, value) {
            final String label = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'label']),
                dxContext,
                pathContext);
            final String propertyValueRef =
                getDataPropertyRecursive(node, ['config', 'value']);
            final value = resolveFormPropertyValue(
                propertyValueRef, dxContext, pathContext);
            final String required =
                getDataPropertyRecursive(node, ['config', 'required']);
            return InputInteger(
                label,
                value,
                required == 'true',
                (value) => dxStore.dispatch(UpdateCurrentFormData(
                    propertyValueRef, pathContext, value)));
          });
    case 'viewcontainer':
    case 'flowcontainer':
      return skipNode(node, context, pathContext, dxContext);
    case 'view':
      if (getDataPropertyRecursive(node, ['config', 'ruleClass']) != null) {
        // TODO this finished assignment detection logic based on "showList"
        final String showList = getDataPropertyRecursive(
            getCurrentPage(), ['data', 'content', 'showList']);
        if (showList == 'false') {
          final String actionId = node['name'];
          final ActionData actionData = resolveActionData(actionId, dxContext);
          if (actionData != null) {
            return AssignmentForm(actionData,
                getChildWidgets(node, context, pathContext, dxContext));
          }
          return skipNode(node, context, pathContext, dxContext);
        }
        return Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 40),
          child: Column(
            children: [
              Text('We are done here!',
                  style: Theme.of(context).textTheme.headline),
              Container(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(getIconData('pi-check')))
            ],
          ),
        );
      }
      return skipNode(node, context, pathContext, dxContext);
    case 'pulse':
    case 'pxautocomplete':
    case 'scalar':
    case 'utility':
      print('sorry, "$nodeType" node type is not supported. For the purpose of this demo, ' +
          'not all DX API features are supported. You can still submit an issue at ' +
          'https://github.com/Pegasystems-Krakow/dx-flutter-demo');
      return null;
  }
  return ErrorBox(
      'Ops!, unable to render "$nodeType" node type. Please submit a bug or, even better, ' +
          'a pull request at https://github.com/Pegasystems-Krakow/dx-flutter-demo');
}
