// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dx_interpreter.dart';

final String _username = 'user@constellation.com';
final String _password = 'rules';
// final String _baseUrl = 'https://lu-84-cam.eng.pega.com';
final String _baseUrl = 'http://l35942meu.rpega.com:1080';

final _headers = {
  'Accept': 'application/json',
  'Authorization':
      'Basic ' + base64.encode(utf8.encode(_username + ':' + _password))
};

Future<UnmodifiableMapView<String, dynamic>> getPortal(String portalName) async {
  final response = await http
      .get(_baseUrl + '/prweb/api/v2/portals/$portalName', headers: _headers);
  return getImmutableCopy(json.decode(response.body));
}

Future<UnmodifiableMapView<String, dynamic>> getPage(String pyRuleName, String pyClassName) async {
  final response = await http.get(
      _baseUrl + '/prweb/api/v2/pages/$pyRuleName?pageClass=$pyClassName',
      headers: _headers);
  return getImmutableCopy(json.decode(response.body));
}

Future<UnmodifiableMapView<String, dynamic>> openAssignment(String pzInsKey) async {
  final response = await http
      .get(_baseUrl + '/prweb/api/v2/assignments/$pzInsKey', headers: _headers);
  return getImmutableCopy(json.decode(response.body));
}

Future<UnmodifiableMapView<String, dynamic>> createAssignment(String caseTypeID, String processID) async {
  final String postData = json.encode({'caseTypeID': caseTypeID, 'processID': processID});
  final response = await http
      .post(_baseUrl + '/prweb/api/v2/cases', headers: _headers, body: postData);
  return getImmutableCopy(json.decode(response.body));
}

Future<UnmodifiableMapView<String, dynamic>> processAssignment(String assignmentId, String actionName, Map payload) async {
  final String patchData = json.encode(payload ?? {'content': {}});
  final response = await http
      .patch(_baseUrl + '/prweb/api/v2/assignments/$assignmentId/actions/$actionName', headers: _headers, body: patchData);
  return getImmutableCopy(json.decode(response.body));
}
