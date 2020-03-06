// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

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

List<Widget> getWidgets(List<dynamic> nodes, BuildContext context,
    {DxContext dxContext = DxContext.currentPage}) {
  if (nodes != null) {
    return nodes
        .map((node) => getWidget(node, context, dxContext: dxContext))
        .where((widget) => widget != null)
        .toList();
  }
  return null;
}

// in some cases the given node won't have a representation in the application's layout
// this method will skip one node to continue rendering its children
Widget skipNode(Map node, BuildContext context,
    {DxContext dxContext = DxContext.currentPage}) {
  final List children = node['children'] is List ? node['children'] : [];
  if (children.length > 1) {
    return Expanded(
        child: Column(
            children: getWidgets(children, context, dxContext: dxContext)));
  }
  return getWidget(children.first, context, dxContext: dxContext);
}

/// method responsible for spitting out flutter widgets based on the current ui metadata node and context data
Widget getWidget(Map node, BuildContext context,
    {DxContext dxContext = DxContext.currentPage}) {
  // check if node has a reference to another arbitrary leaf in the ui metadata tree
  if (hasReference(node)) {
    node = getReferencedNode(node, dxContext);
  }

  final String nodeType = node['type'];
  // based on the node's type, the appropriate widget is chosen
  switch (nodeType) {
    case 'Table':
      final List items = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'referenceList']),
          dxContext);
      return AssignmentsList(items, 'pzInsKey', 'pyLabel', 'pxRefObjectInsName',
          'pxUrgencyAssign', 'pyAssignmentStatus');
    case 'Todo':
      final List assignments = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'assignmentsList']),
          dxContext);
      return AssignmentsList(assignments.take(3).toList(), 'pzInsKey',
          'pyLabel', 'pxRefObjectKey', 'pxUrgencyAssign', 'pyAssignmentStatus');
    case 'Region':
      final String name = node['name'];
      final List children = node['children'] is List ? node['children'] : [];
      return Region(name, children);
    case 'Page':
      String title = getDataPropertyRecursive(node, ['config', 'title']);
      if (title != null && title.isNotEmpty) {
        final String operator = resolvePropertyValue(
            getDataPropertyRecursive(node, ['config', 'operator']), dxContext);
        if (operator != null && operator.isNotEmpty) {
          title += ', $operator';
        }
      }
      return Page(title, node['children']);
    case 'AppShell':
      final String appName = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'appName']), dxContext);
      final List pages = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'pages']), dxContext);
      final List caseTypes = getListFromDataSource(
          getDataPropertyRecursive(node, ['config', 'caseTypes']), dxContext);
      final List children = node['children'] is List ? node['children'] : [];
      final Map currentPage = children.first;
      // dx store's current page is set only if not yet initialized
      // subsequent "InitCurrentPage" actions (eg. during hot-reloading) won't take effect
      dxStore.dispatch(InitCurrentPage(currentPage));
      return AppShell(appName, pages, caseTypes);
    case 'CaseView':
      final String label = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'heading']), dxContext);
      final String id = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'id']), dxContext);
      final String iconName =
          getDataPropertyRecursive(node, ['config', 'icon']);
      final List children = node['children'] is List ? node['children'] : [];
      return CaseView(label, id, iconName, children);
    case 'CaseSummary':
      final List primaryFields = resolvePropertyValues(
          getDataPropertyRecursive(node, ['config', 'primaryFields']),
          'value',
          dxContext);
      final List secondaryFields = resolvePropertyValues(
          getDataPropertyRecursive(node, ['config', 'secondaryFields']),
          'value',
          dxContext);
      final String status = resolvePropertyValue(
          getDataPropertyRecursive(node, ['config', 'status']), dxContext);
      return CaseSummary(status, primaryFields, secondaryFields);
    case 'Stages':
      return StoreConnector<Map, dynamic>(
          converter: (store) => getCurrentPageData(),
          distinct: true,
          builder: (context, value) {
            final List stages = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'stages']),
                dxContext);
            return CaseStageIndicator(stages);
          });
    case 'TextInput':
      return StoreConnector<Map, dynamic>(
          converter: (store) => getCurrentFormData(),
          distinct: true,
          builder: (context, value) {
            final String label = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'label']), dxContext);
            final String propertyValueRef =
                getDataPropertyRecursive(node, ['config', 'value']);
            final value = resolveFormPropertyValue(propertyValueRef, dxContext);
            final String required =
                getDataPropertyRecursive(node, ['config', 'required']);
            return InputText(
                label,
                value,
                required == 'true',
                (value) => dxStore
                    .dispatch(UpdateCurrentFormData(propertyValueRef, value)));
          });
    case 'Dropdown':
      return StoreConnector<Map, dynamic>(
          converter: (store) => getCurrentFormData(),
          distinct: true,
          builder: (context, value) {
            final List options = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'datasource']),
                dxContext);
            final String label = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'label']), dxContext);
            final String propertyValueRef =
                getDataPropertyRecursive(node, ['config', 'value']);
            final value = resolveFormPropertyValue(propertyValueRef, dxContext);
            final String required =
                getDataPropertyRecursive(node, ['config', 'required']);
            return InputSelect(
                label,
                value,
                required == 'true',
                options,
                (value) => dxStore
                    .dispatch(UpdateCurrentFormData(propertyValueRef, value)));
          });
    case 'Integer':
      return StoreConnector<Map, dynamic>(
          converter: (store) => getCurrentFormData(),
          distinct: true,
          builder: (context, value) {
            final String label = resolvePropertyValue(
                getDataPropertyRecursive(node, ['config', 'label']), dxContext);
            final String propertyValueRef =
                getDataPropertyRecursive(node, ['config', 'value']);
            final value = resolveFormPropertyValue(propertyValueRef, dxContext);
            final String required =
                getDataPropertyRecursive(node, ['config', 'required']);
            return InputInteger(
                label,
                value,
                required == 'true',
                (value) => dxStore
                    .dispatch(UpdateCurrentFormData(propertyValueRef, value)));
          });
    case 'ViewContainer':
    case 'FlowContainer':
      return skipNode(node, context, dxContext: dxContext);
    case 'View':
      if (getDataPropertyRecursive(node, ['config', 'ruleClass']) != null) {
        // TODO this finished assignment detection logic based on "showList"
        final String showList = getDataPropertyRecursive(
            getCurrentPage(), ['data', 'content', 'showList']);
        if (showList == 'false') {
          final String actionId = node['name'];
          final ActionData actionData = resolveActionData(actionId, dxContext);
          final List children =
              node['children'] is List ? node['children'] : [];
          return AssignmentForm(actionData, children);
        }
        return Expanded(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('We are done here!',
              style: Theme.of(context).textTheme.headline),
          Icon(getIconData('pi-check'))
        ]));
      }
      return skipNode(node, context, dxContext: dxContext);
    case 'Pulse':
    case 'pxAutoComplete':
    case 'Scalar':
    case 'Utility':
      print('sorry, "$nodeType" node type is not supported. For the purpose of this demo, ' +
          'not all DX API features are supported. You can still submit an issue at ' +
          'https://github.com/Pegasystems-Krakow/dx-flutter-demo');
      return null;
  }
  return ErrorBox(
      'Ops!, unable to render "$nodeType" node type. Please submit a bug or, even better, ' +
          'a pull request at https://github.com/Pegasystems-Krakow/dx-flutter-demo');
}

// ======== OLD ============
//    case 'label':
////      const propertiesToResolve = {
////        'text': ['config', 'value'],
////        'format': ['config', 'format']
////      };
////      final onRender = (context, node, data, resolvedProperties) =>
////          Label(resolvedProperties['text'].value, resolvedProperties['format'].value);
////
////      return renderWithResolvedProperties(context, node, data, propertiesToResolve, onRender);
//
//      String text = getDataPropertyRecursive(node, ['config', 'text']) ?? '';
//      if (text.startsWith('.')) {
//        text = getDataPropertyRecursive(
//            data, ['data', 'pyWorkPage', text.replaceFirst('.', '')]);
//      }
//
//      final format = getDataPropertyRecursive(node, ['config', 'format']);
//      return Label(text, format);
//
//    case 'screenlayout':
//      // TODO this is hacking to make top/left/center layout conform to Scaffold layout
//      final List<dynamic> children = node['children'];
//      final top = children.firstWhere((child) => child['type'] == 'TOP',
//          orElse: () => null);
//      final left = children.firstWhere((child) => child['type'] == 'LEFT',
//          orElse: () => null);
//      final center = children.firstWhere((child) => child['type'] == 'CENTER',
//          orElse: () => null);
//
//      if (top != null && left != null) {
//        return Scaffold(
//            resizeToAvoidBottomInset: true,
//            appBar: AppBar(title: getWidget(top, data, context)),
//            body: getWidget(center, data, context),
//            drawer: Drawer(child: getWidget(left, data, context)));
//      }
//
//      return Scaffold(
//        resizeToAvoidBottomInset: true,
//        body: SafeArea(
//            child:
//                SingleChildScrollView(child: getWidget(center, data, context))),
//      );
//    case 'TOP':
//    case 'LEFT':
//    case 'CENTER':
//    case 'ajaxcontainer':
//    case 'harness':
//      return _getWidgets(node['children'], data, context).first; // invisible
//
//    case 'section':
//      final List<dynamic> children = node['children'];
//      if (children.length > 1) {
//        return Column(children: _getWidgets(children, data, context));
//      }
//      return getWidget(children.first, data, context); // invisible
//
//    case 'layout':
//      final List<dynamic> children = node['children'];
//      if (children.length > 1) {
//        if (node['config']['format'] == 'Card') {
//          List<Widget> childWidgets = _getWidgets(children, data, context);
//
//          if (node['config']['title'] != null) {
//            childWidgets.insert(
//                0,
//                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                  Container(
//                    padding: EdgeInsets.all(10),
//                    child: Text(node['config']['title']),
//                  )
//                ]));
//          }
//          return Card(
//              // wrapped
//              child: Container(
//            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
//            child: Wrap(spacing: 8.0, runSpacing: 4.0, children: childWidgets),
//          ));
//        } else if (node['config']['format'] == 'Default') {
//          return Card(
//              // wrapped
//              child: Container(
//            padding: EdgeInsets.all(10),
//            constraints: BoxConstraints(minWidth: double.infinity),
//            child: Column(children: _getWidgets(children, data, context)),
//          ));
//        }
//        return Column(children: _getWidgets(children, data, context));
//      }
//      return getWidget(children.first, data, context); // invisible
//
//    case 'navitemlist':
//      final repeat = node['repeat'] == 'true';
//      final dataSourcePathName = node['context'];
//      if (repeat && dataSourcePathName != null) {
//        final child = node['children'].first;
//        final action = child['config']['actions'].first;
//        List flows = getListFromDataSource(data['data'], dataSourcePathName);
//        return Card(
//          child: Column(
//              children: flows
//                  .map((flow) {
//                    return {
//                      'type': child['type'],
//                      'config': {
//                        'caption': flow['pyLabel'],
//                        'actions': [
//                          getMergedImmutableCopy(action, {
//                            'config': {
//                              'class': flow['pyClassName'],
//                              'flowName': flow['pyFlowType']
//                            }
//                          })
//                        ]
//                      }
//                    };
//                  })
//                  .map((node) => getWidget(node, data, context))
//                  .toList()),
//        );
//      }
//
//      return Column(
//        children: [..._getWidgets(node['children'], data, context), Divider()],
//      );
//
//    case 'navigation':
//      return ListView(
//        padding: EdgeInsets.zero,
//        children: [
//          DrawerHeader(
//            child: Text('Menu'),
//            decoration: BoxDecoration(
//              color: Colors.blue,
//            ),
//          ),
//          ..._getWidgets(node['children'], data, context)
//        ],
//      );
//
//    case 'navitem':
//      String caption =
//          getDataPropertyRecursive(node, ['config', 'caption']) ?? '';
//      return ListTile(
//        title: Text(caption),
//        onTap: () {
//          Navigator.pop(context);
//          final action =
//              getDataPropertyRecursive(node, ['config', 'actions']).first;
//          navigateTo('assignment/create/' + action['config']['class']);
//        },
//      );
//
//    case 'stages':
//      final dsName = node['config']['datasource'];
//      String currentStageName = node['config']['activeStage'];
//      if (currentStageName.startsWith('.')) {
//        currentStageName = getDataPropertyRecursive(data,
//            ['data', 'pyWorkPage', currentStageName.replaceFirst('.', '')]);
//      }
//      final contextPageLists = data['ContextData']['pyWorkPage']['\$pagelists'];
//      final actualDsName = contextPageLists[dsName];
//      final Iterable<String> stageNames =
//          getListFromDataSource(data['data'], actualDsName)
//              .map((child) => child['pyStageName']);
//      return CaseStageIndicator(stageNames, currentStageName);
//
//    case 'repeatinglayout':
//      final repeat = node['repeat'] == 'true';
//      final dataSourcePathName = node['config']['datasource'];
//      if (repeat == true && dataSourcePathName != null) {
//        return ListView(
//            children: getListFromDataSource(data['data'], dataSourcePathName)
//                .map((dynamic child) => Card(
//                    child: ListTile(
//                        title: Text(child['pxRefObjectInsName']),
//                        subtitle: Text(
//                            child['pxTaskLabel'] + ' | ' + child['pyLabel']),
//                        trailing: Icon(Icons.arrow_forward),
//                        onTap: () =>
//                            navigateTo('assignment/' + child['pzInsKey']))))
//                .toList());
//      }
//      return ListView(children: _getWidgets(node['children'], data, context));
//
//    case 'text':
////      const propertiesToResolve = {
////        'label': ['config', 'label'],
////        'text': ['config', 'text']
////      };
////      final onRender = (context, node, data, resolvedProperties) =>
////          WrappedTextField(resolvedProperties['label'].value, resolvedProperties['text'].value);
////
////      return renderWithResolvedProperties(context, node, data, propertiesToResolve, onRender);
//
//      final label = getDataPropertyRecursive(node, ['config', 'label']);
//      String text = getDataPropertyRecursive(node, ['config', 'text']);
//      if (text.startsWith('.')) {
//        text = getDataPropertyRecursive(
//            data, ['data', 'pyWorkPage', text.replaceFirst('.', '')]);
//      }
//      return WrappedTextField(label, text);
//
//    case 'textinput':
//      // TODO add support for localization
////      const propertiesToResolve = {
////        'label': ['config', 'label'],
////        'value': ['config', 'value']
////      };
////      final onRender = (context, node, data, resolvedProperties) =>
////          InputText(
////              resolvedProperties['label'].value,
////              resolvedProperties['value'].value,
////              (String value) => resolvedProperties['value'].update(value)
////          );
////
////      return renderWithResolvedProperties(context, node, data, propertiesToResolve, onRender);
//
//      final label = node['config']['label'].replaceFirst('@L ', '');
//      final stateKey = node['config']['value'].replaceFirst('.', '');
//      final stateValue =
//          getDataPropertyRecursive(data, ['data', 'pyWorkPage', stateKey]);
//      final onchange =
//          (String value) => constellationStore.dispatch(UpdateStateAction({
//                'data': {
//                  'pyWorkPage': {stateKey: value}
//                }
//              }));
//      return InputText(label, stateValue, onchange);
//
//    case 'date':
//      final label = node['config']['label'];
//      final stateKey = node['config']['value'].replaceFirst('.', '');
//      final stateValue =
//          getDataPropertyRecursive(data, ['data', 'pyWorkPage', stateKey]);
//      final onchange =
//          (DateTime value) => constellationStore.dispatch(UpdateStateAction({
//                'data': {
//                  'pyWorkPage': {stateKey: DateFormat.yMMMd().format(value)}
//                }
//              }));
//      return InputDate(
//          label,
//          stateValue != null && stateValue != ''
//              ? DateFormat.yMMMd().parse(stateValue)
//              : DateTime.now(),
//          onchange);
//
//    case 'daterange':
//      final label = getDataPropertyRecursive(node, ['config', 'label']) ?? '';
//      final dateFromKey =
//          getDataPropertyRecursive(node, ['config', 'fromDateValue'])
//              .replaceFirst('.', '');
//      final dateToKey =
//          getDataPropertyRecursive(node, ['config', 'toDateValue'])
//              .replaceFirst('.', '');
//      final dateFromValue =
//          getDataPropertyRecursive(data, ['data', 'pyWorkPage', dateFromKey]);
//      final dateToValue =
//          getDataPropertyRecursive(data, ['data', 'pyWorkPage', dateToKey]);
//      final onchange = (DateTime dateFrom, DateTime dateTo) =>
//          constellationStore.dispatch(UpdateStateAction({
//            'data': {
//              'pyWorkPage': {
//                dateFromKey: DateFormat.yMMMd().format(dateFrom),
//                dateToKey: DateFormat.yMMMd().format(dateTo)
//              }
//            }
//          }));
//      return InputDateRange(
//          label,
//          dateFromValue != null && dateFromValue != ''
//              ? DateFormat.yMMMd().parse(dateFromValue)
//              : DateTime.now().add(Duration(days: 1)),
//          dateToValue != null && dateToValue != ''
//              ? DateFormat.yMMMd().parse(dateToValue)
//              : DateTime.now().add(Duration(days: 7)),
//          onchange);
//
//    case 'button':
//      return Container(
//        padding: EdgeInsets.only(top: 5),
//        child: Row(mainAxisSize: MainAxisSize.max, children: [
//          Expanded(
//              child: RaisedButton(
//                  child: Text(node['config']['label']),
//                  onPressed: () {
//                    final action = node['config']['actions'].first;
//                    final pyWorkPage =
//                        getDataPropertyRecursive(data, ['data', 'pyWorkPage']);
//                    final delta = getDataPropertyRecursive(
//                            constellationStore.state, ['data', 'pyWorkPage']) ??
//                        {};
//                    final payload = getMergedImmutableCopy(pyWorkPage, delta);
//                    if (action['name'] == 'finishAssignment') {
//                      navigateTo(
//                          'assignment/' + pyWorkPage['pzInsKey'] + '/next',
//                          withData: payload);
//                    } else if (action['name'] == 'addWork') {
//                      navigateTo('assignment/add', withData: payload);
//                    }
//                  }))
//        ]),
//      );
//
//    case 'select':
////      const propertiesToResolve = {
////        'label': ['config', 'label'],
////        'value': ['config', 'value']
////      };
////      final onRender = (context, node, data, resolvedProperties) =>
////          InputText(
////              resolvedProperties['label'].value,
////              resolvedProperties['value'].value,
////                  (String value) => resolvedProperties['value'].update(value)
////          );
////
////      return renderWithResolvedProperties(context, node, data, propertiesToResolve, onRender);
//
//      final label = node['config']['label'];
//      final stateKey = node['config']['value'].replaceFirst('.', '');
//      final stateValue =
//          getDataPropertyRecursive(data, ['data', 'pyWorkPage', stateKey]);
//      final dataSourcePathName = node['config']['datasource'];
//      final dataSourceSelectValueName =
//          node['config']['selectValue'].replaceFirst('.', '');
//      final Iterable<String> options =
//          getListFromDataSource(data['data'], dataSourcePathName).map(
//              (dynamic dsValue) =>
//                  dsValue[dataSourceSelectValueName] as String);
//      final onchange =
//          (String newValue) => constellationStore.dispatch(UpdateStateAction({
//                'data': {
//                  'pyWorkPage': {stateKey: newValue}
//                }
//              }));
//      return InputSelect(label, stateValue, options, onchange);
