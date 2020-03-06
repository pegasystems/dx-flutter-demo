// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:async';

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

Map _replaceCurrentPage(Map state, Map page) {
  final mutableState = Map.from(state);
  if (page['root'] == null) {
    page = Map.unmodifiable({'root': page});
  }
  mutableState['fetchingData'] = false;
  mutableState['currentFormData'] = null;
  mutableState[DxContext.currentPage.toString()] = page;
  return Map.unmodifiable(mutableState);
}

// redux store reducers
final _reducer = combineReducers<Map>([
  TypedReducer<Map, SetCurrentPortal>((state, action) {
    return getMergedImmutableCopy(
        state, {DxContext.currentPortal.toString(): action.portal});
  }),
  TypedReducer<Map, InitCurrentPage>((state, action) {
    if (state[DxContext.currentPage.toString()] == null) {
      return _replaceCurrentPage(state, action.page);
    }
    return state;
  }),
  TypedReducer<Map, SetCurrentPage>((state, action) {
    return _replaceCurrentPage(state, action.page);
  }),
  TypedReducer<Map, UpdateCurrentPage>((state, action) {
    return getMergedImmutableCopy(state, {
      'fetchingData': false,
      'currentFormData': null,
      DxContext.currentPage.toString(): action.data
    });
  }),
  TypedReducer<Map, FetchPage>((state, action) {
    return getMergedImmutableCopy(state, {
      'fetchingData': true,
      'contextButtonsVisibility': initialContextButtonsVisibility
    });
  }),
  TypedReducer<Map, ProcessAssignment>((state, action) {
    return getMergedImmutableCopy(state, {
      'fetchingData': true,
      'contextButtonsVisibility': initialContextButtonsVisibility
    });
  }),
  TypedReducer<Map, AddError>((state, action) {
    return getMergedImmutableCopy(
        state, {'fetchingData': false, 'lastError': action.errorData});
  }),
  TypedReducer<Map, RemoveError>((state, action) {
    return getMergedImmutableCopy(state, {'lastError': null});
  }),
  TypedReducer<Map, OpenAssignment>((state, action) {
    return getMergedImmutableCopy(state, {'fetchingData': true});
  }),
  TypedReducer<Map, ToggleCustomButtonsVisibility>((state, action) {
    return getMergedImmutableCopy(state, {
      'contextButtonsVisibility': action.buttonToggles.map(
          (DxContextButtonAction button, bool shouldDisplay) =>
              MapEntry(button.toString(), shouldDisplay))
    });
  }),
  TypedReducer<Map, UpdateCurrentFormData>((state, action) {
    final String propertyKey =
        action.propertyValueReference.split('@P').last.split('.').last;
    return getMergedImmutableCopy(state, {
      'currentFormData': {propertyKey: action.value}
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
  final Map page;

  const InitCurrentPage(this.page);
}

class SetCurrentPage {
  final Map page;

  const SetCurrentPage(this.page);
}

class UpdateCurrentPage {
  final Map data;

  const UpdateCurrentPage(this.data);
}

class SetCurrentPortal {
  final Map portal;

  const SetCurrentPortal(this.portal);
}

class OpenAssignment {
  final String pzInsKey;

  const OpenAssignment(this.pzInsKey);
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
  final value;

  const UpdateCurrentFormData(this.propertyValueReference, this.value);
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

final initialContextButtonsVisibility = Map.unmodifiable({
  DxContextButtonAction.submit.toString(): false,
  DxContextButtonAction.cancel.toString(): false,
  DxContextButtonAction.next.toString(): false,
  DxContextButtonAction.search.toString(): false,
  DxContextButtonAction.filter.toString(): false
});

// redux store initialization
final dxStore = Store<Map>(_reducer,
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
      EpicMiddleware<Map>(_ProcessAssignment()),
    ]);
