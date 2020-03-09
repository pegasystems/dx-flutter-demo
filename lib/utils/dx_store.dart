// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:dx_flutter_demo/utils/dx_interpreter.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';
import 'dx_api.dart';

// ui data/metadata is stored under two different keys inside the redux store,
// based on the current context: portal (updated less often) and page (updated more often)
enum DxContext {
  // current portal metadata context
  currentPortal,
  // current page metadata context
  currentPage
}

UnmodifiableMapView<String, dynamic> _replaceCurrentPage(
    UnmodifiableMapView<String, dynamic> state,
    UnmodifiableMapView<String, dynamic> page) {
  final mutableState = Map<String, dynamic>.from(state);
  if (page['root'] == null) {
    page = Map<String, dynamic>.unmodifiable({'root': page});
  }
  mutableState['fetchingData'] = false;
  mutableState['currentFormData'] = null;
  mutableState[DxContext.currentPage.toString()] = page;
  return Map<String, dynamic>.unmodifiable(mutableState);
}

// redux store reducers
final _reducer = combineReducers<UnmodifiableMapView<String, dynamic>>([
  TypedReducer<UnmodifiableMapView<String, dynamic>, SetCurrentPortal>(
      (state, action) {
    return getMergedImmutableCopy(
        state, {DxContext.currentPortal.toString(): action.portal});
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, InitCurrentPage>(
      (state, action) {
    if (state[DxContext.currentPage.toString()] == null) {
      return _replaceCurrentPage(state, action.page);
    }
    return state;
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, SetCurrentPage>(
      (state, action) {
    return _replaceCurrentPage(state, action.page);
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, UpdateCurrentPage>(
      (state, action) {
    return getMergedImmutableCopy(state, {
      'fetchingData': false,
      'currentFormData': null,
      DxContext.currentPage.toString(): action.data
    });
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, FetchPage>(
      (state, action) {
    return getMergedImmutableCopy(state, {
      'fetchingData': true,
      'contextButtonsVisibility': initialContextButtonsVisibility
    });
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, ProcessAssignment>(
      (state, action) {
    return getMergedImmutableCopy(state, {
      'fetchingData': true,
      'contextButtonsVisibility': initialContextButtonsVisibility
    });
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, AddError>((state, action) {
    return getMergedImmutableCopy(
        state, {'fetchingData': false, 'lastError': action.errorData});
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, RemoveError>(
      (state, action) {
    return getMergedImmutableCopy(state, {'lastError': null});
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, OpenAssignment>(
      (state, action) {
    return getMergedImmutableCopy(state, {'fetchingData': true});
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, CreateAssignment>(
          (state, action) {
        return getMergedImmutableCopy(state, {'fetchingData': true});
      }),
  TypedReducer<UnmodifiableMapView<String, dynamic>,
      ToggleCustomButtonsVisibility>((state, action) {
    return getMergedImmutableCopy(state, {
      'contextButtonsVisibility': action.buttonToggles.map(
          (DxContextButtonAction button, bool shouldDisplay) =>
              MapEntry<String, bool>(button.toString(), shouldDisplay))
    });
  }),
  TypedReducer<UnmodifiableMapView<String, dynamic>, UpdateCurrentFormData>(
      (state, action) {
    final String propertyKey =
        action.propertyValueReference.split('@P').last.split('.').last;
    final Map formUpdate = action.pathContext
        .split('.')
        .reversed
        .fold({propertyKey: action.value}, (Map data, String pathKey) {
          if (pathKey != null && pathKey.isNotEmpty) {
            return {pathKey: data};
          }
          return data;
        });
    return getMergedImmutableCopy(state, {
      'currentFormData': formUpdate
    });
  })
]);

// redux epi definitions

class _FetchPortalEpic implements EpicClass<Map> {
  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<Map> store) =>
      Observable(actions)
          .whereType<FetchPortal>()
          .asyncMap((action) => getPortal(action.portalName))
          .map((data) => SetCurrentPortal(data));
}

class _FetchPageEpic implements EpicClass<Map> {
  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<Map> store) =>
      Observable(actions)
          .whereType<FetchPage>()
          .asyncMap((action) => getPage(action.pyRuleName, action.pyClassName))
          .map((data) => SetCurrentPage(data));
}

class _OpenAssignmentEpic implements EpicClass<Map> {
  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<Map> store) =>
      Observable(actions)
          .whereType<OpenAssignment>()
          .asyncMap((action) => openAssignment(action.pzInsKey))
          .map((data) => SetCurrentPage(data));
}

class _CreateAssignmentEpic implements EpicClass<Map> {
  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<Map> store) =>
      Observable(actions)
          .whereType<CreateAssignment>()
          .asyncMap((action) => createAssignment(action.pyClassName, action.pyFlowType))
          .map((data) => SetCurrentPage(data));
}

class _ProcessAssignment implements EpicClass<Map> {
  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<Map> store) =>
      Observable(actions).whereType<ProcessAssignment>().asyncMap((action) {
        final payload = getCurrentFormData();
        return processAssignment(
            action.actionData.caseId, action.actionData.id, payload);
      }).map((data) {
        if (data.containsKey('errorDetails')) {
          return AddError(data);
        }
        if (data.containsKey('root')) {
          return SetCurrentPage(data);
        }
        return UpdateCurrentPage(data);
      });
}

// redux actions

class FetchPortal {
  final String portalName;

  const FetchPortal(this.portalName);
}

class FetchPage {
  final String pyRuleName;
  final String pyClassName;

  const FetchPage(this.pyRuleName, this.pyClassName);
}

/// this action updates the current page data *only* if it's not been initialized yet
/// this action is useful to avoid changing the current page during hot reloading
/// SetCurrentPage should be used to update it unconditionally
class InitCurrentPage {
  final UnmodifiableMapView<String, dynamic> page;

  const InitCurrentPage(this.page);
}

class SetCurrentPage {
  final UnmodifiableMapView<String, dynamic> page;

  const SetCurrentPage(this.page);
}

class UpdateCurrentPage {
  final UnmodifiableMapView<String, dynamic> data;

  const UpdateCurrentPage(this.data);
}

class SetCurrentPortal {
  final UnmodifiableMapView<String, dynamic> portal;

  const SetCurrentPortal(this.portal);
}

class OpenAssignment {
  final String pzInsKey;

  const OpenAssignment(this.pzInsKey);
}

class CreateAssignment {
  final String pyClassName;
  final String pyFlowType;

  const CreateAssignment(this.pyClassName, this.pyFlowType);
}

// button actions available depending on the current page context
enum DxContextButtonAction { submit, cancel, next, search, filter }

// this stream allows widgets to listen to actions coming from higher level widgets
// for example, scaffold's floating button emitting an event to inform a child form
// widget that is time to validate and submit the data
// this flow of events is not part of redux but for simplicity and convenience it's
// declared here
StreamController<DxContextButtonAction> contextButtonActions =
    new StreamController.broadcast();

class ToggleCustomButtonsVisibility {
  final Map<DxContextButtonAction, bool> buttonToggles;

  const ToggleCustomButtonsVisibility(this.buttonToggles);
}

class UpdateCurrentFormData {
  final String propertyValueReference;
  final String pathContext;
  final value;

  const UpdateCurrentFormData(this.propertyValueReference, this.pathContext, this.value);
}

class ProcessAssignment {
  final ActionData actionData;

  const ProcessAssignment(this.actionData);
}

class AddError {
  final Map errorData;

  const AddError(this.errorData);
}

class RemoveError {
  const RemoveError();
}

final initialContextButtonsVisibility = Map<String, dynamic>.unmodifiable({
  DxContextButtonAction.submit.toString(): false,
  DxContextButtonAction.cancel.toString(): false,
  DxContextButtonAction.next.toString(): false,
  DxContextButtonAction.search.toString(): false,
  DxContextButtonAction.filter.toString(): false
});

// redux store initialization
final dxStore = Store<UnmodifiableMapView<String, dynamic>>(_reducer,
    initialState: Map<String, dynamic>.unmodifiable({
      'fetchingData': false,
      'contextButtonsVisibility': initialContextButtonsVisibility,
      'lastError': null,
      'currentFormData': null,
    }),
    middleware: [
      EpicMiddleware<Map>(_FetchPortalEpic()),
      EpicMiddleware<Map>(_FetchPageEpic()),
      EpicMiddleware<Map>(_OpenAssignmentEpic()),
      EpicMiddleware<Map>(_CreateAssignmentEpic()),
      EpicMiddleware<Map>(_ProcessAssignment()),
    ]);
