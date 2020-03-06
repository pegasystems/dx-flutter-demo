// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:dx_flutter_demo/utils/dx_store.dart';

// data helpers

Map getWorkObjectData(DxContext dxContext) =>
    _getDxContextData(dxContext, 'data')['content'];

Map getCurrentPortal() => getDataPropertyRecursive(
    dxStore.state, [DxContext.currentPortal.toString()]);

Map getCurrentPage() => dxStore.state[DxContext.currentPage.toString()];

Map getCurrentPageData() =>
    getDataPropertyRecursive(getCurrentPage(), ['data']);

String getCurrentPageClassName() => getDataPropertyRecursive(
    getCurrentPage(), ['data', 'case_summary', 'caseClass']);

Map getContextButtonsVisibility(Map data) => data['contextButtonsVisibility'];

Map getCurrentFormData() => dxStore.state['currentFormData'];

Map _getDxContextData(DxContext dxContext, String key) {
  Map contextData = dxStore.state[dxContext.toString()];
  if (contextData != null && contextData[key] != null) {
    return contextData[key];
  }
  // fallback to Portal data lookup
  if (dxContext == DxContext.currentPage) {
    return _getDxContextData(DxContext.currentPortal, key);
  }
  return null;
}

/// little helper which recursively traverses map data based on an array of string keys
dynamic getDataPropertyRecursive(Map data, List<String> keys) {
  if (keys.length > 0) {
    if (data != null && data.containsKey(keys.first)) {
      if (keys.length > 1) {
        final nestedData = data[keys.first];
        if (nestedData is Map) {
          return getDataPropertyRecursive(data[keys.first], keys.sublist(1));
        }
        return null;
      }
      return data[keys.first];
    }
  }
  return null;
}

/// gets a list of dynamic objects based on a datasource string path name, which contains dots (".")
/// in order to separate the path parts/components. eg "MyDataSource.pxResults"
List<dynamic> getListFromDataSource(
    String dataSourcePath, DxContext dxContext) {
  final data = _getDxContextData(dxContext, 'data');
  final result = getDataPropertyRecursive(data, dataSourcePath.split('.'));
  if (result != null && result is List<dynamic>) {
    return result;
  }
  return [];
}

String getRootContext(DxContext dxContext) {
  Map rootNode = getRootNode(dxStore.state[dxContext.toString()]);
  return getDataPropertyRecursive(rootNode, ['config', 'context']);
}

ActionData resolveActionData(String actionId, DxContext dxContext) {
  final Map data = _getDxContextData(dxContext, 'data');
  final List actions =
      getDataPropertyRecursive(data, ['case_summary', 'actions']);
  final Map action = actions.firstWhere((action) => action['ID'] == actionId);
  final String caseId = getDataPropertyRecursive(data, ['case_summary', 'ID']);
  return ActionData(action['name'], action['ID'], action['type'], caseId);
}

class ActionData {
  final String name;
  final String id;
  final String type;
  final String caseId;

  const ActionData(this.name, this.id, this.type, this.caseId);
}

dynamic resolveFormPropertyValue(String reference, DxContext dxContext) {
  String propertyKey = reference.split('@P').last.trim().split('.').last;
  Map formData = getCurrentFormData();
  if (formData != null && formData.containsKey(propertyKey)) {
    return formData[propertyKey];
  }
  return resolvePropertyValue(reference, dxContext);
}

dynamic resolvePropertyValue(String reference, DxContext dxContext) {
  if (reference != null) {
    if (reference.startsWith('@P')) {
      String path = reference.split('@P ').last.trimLeft();
      if (path.startsWith('.')) {
        path = getRootContext(dxContext) + path;
      }
      final data = _getDxContextData(dxContext, 'data');
      return getDataPropertyRecursive(data, path.split('.'));
    }
    if (reference.startsWith('@L')) {
      String label = reference.split('@L ').last.trimLeft();
      return label;
    }
    if (reference.startsWith('@ASSOCIATED')) {
      String path = reference.split('@ASSOCIATED ').last.trimLeft();
      if (path.startsWith('.')) {
        path = 'content.summary_of_associated_lists__' + path;
      }
      final data = _getDxContextData(dxContext, 'context_data');
      return getDataPropertyRecursive(data, path.split('.'));
    }
  }
  return reference;
}

List resolvePropertyValues(List fields, key, DxContext dxContext) {
  return List.unmodifiable(fields.map((field) {
    if (field.containsKey(key)) {
      final mutableField = Map.from(field);
      mutableField['value'] = resolvePropertyValue(field[key], dxContext);
      return Map.unmodifiable(mutableField);
    }
    return field;
  }).toList());
}

bool hasReference(Map node) => 'reference' == node['type'];

/// takes a ui metadata node and returns all key references to data stored
/// in constellation redux store which makes it required to listen to changes
List<String> getStoreRefKeys(Map node, {String key}) {
  return node.entries
      .where((entry) => entry.key != 'children')
      .fold(List<String>(), (keys, entry) {
    if (entry.value is String && entry.value.startsWith('.')) {
      keys.add(entry.value.replaceFirst('.', ''));
    } else if (entry.value is Map) {
      keys.addAll(getStoreRefKeys(entry.value));
    }
    return keys;
  });
}

// helpers that operate on ui metadata

/// returns the ui metadata node reference dby the given ui metadata node in the given context (portal or page)
UnmodifiableMapView<String, dynamic> getReferencedNode(
    UnmodifiableMapView<String, dynamic> node, DxContext dxContext) {
  final String type = getDataPropertyRecursive(node, ['config', 'type']);
  final String name = resolvePropertyValue(
      getDataPropertyRecursive(node, ['config', 'name']), dxContext);
  switch (type) {
    case 'view':
      final data = dxStore.state[dxContext.toString()];
      final viewData =
          getDataPropertyRecursive(data, ['resources', 'views', name]);
      // fallback to Portal views lookup
      if (viewData == null && dxContext == DxContext.currentPage) {
        final data = dxStore.state[DxContext.currentPortal.toString()];
        return getDataPropertyRecursive(data, ['resources', 'views', name])
            .cast<String, dynamic>();
      }
      return viewData.cast<String, dynamic>();
  }
  return null;
}

/// returns the ui metadata root node for the current data structure (eg. page or portal data)
UnmodifiableMapView<String, dynamic> getRootNode(Map data) =>
    getDataPropertyRecursive(data, ['root']).cast<String, dynamic>();

/// returns a list of child nodes for a given ui metadata node
List<UnmodifiableMapView<String, dynamic>> getChildNodes(
    UnmodifiableMapView<String, dynamic> node) {
  if (node.containsKey('children') && node['children'] is List) {
    List children = node['children'];
    return children.cast<UnmodifiableMapView<String, dynamic>>();
  }
  return List<UnmodifiableMapView<String, dynamic>>();
}

// more generic helpers

/// this method deep-merges to map structures into one inmutable map structure
UnmodifiableMapView<String, dynamic> getMergedImmutableCopy(
    Map targetData, Map updateData) {
  final mergedData = Map<String, dynamic>.from(targetData);
  updateData.keys.forEach((key) {
    mergedData.update(key, (oldValue) {
      if (oldValue is Map && updateData[key] is Map) {
        return getMergedImmutableCopy(Map<String, dynamic>.from(oldValue),
            Map<String, dynamic>.from(updateData[key]));
      }
      return getImmutableCopy(updateData[key]);
    }, ifAbsent: () => getImmutableCopy(updateData[key]));
  });
  return Map<String, dynamic>.unmodifiable(mergedData);
}

/// returns an immutable copy of the provided dynamic data structure (eg. json)
dynamic getImmutableCopy(dynamic data) {
  if (data is Map) {
    return Map<String, dynamic>.unmodifiable(
        data.map((key, value) => MapEntry(key, getImmutableCopy(value))));
  }
  if (data is List) {
    return List<dynamic>.unmodifiable(
        data.map((entry) => getImmutableCopy(entry)));
  }
  return data;
}
