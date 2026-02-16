http.import 'dart:convert';
import 'package:enow/risk/business_unit_role_mapping/models/business_unit_role_mapping_model.dart';
import 'package:http/http.dart' as http;
import 'package:enow/shared/global.dart' as global;
import 'package:enow/shared/api_endpoints.dart' as api;
import 'package:enow/shared/utils.dart' as utils;

// Create
Future<void> createRoleMapping(List<BusinessUnitRoleMapModel> roleMappingList) async {
  var uri = Uri.parse(Uri.encodeFull(api.businessUnitRoleMappingCreateReqStr));
  final http.Response res = await global.api.post(
    uri,
    headers: <String, String>{
      'Content-Type'   : 'application/json; charset=UTF-8',
      'x-access-token' : global.accessToken,
    },
    body: jsonEncode(roleMappingList),
  );

  if (res.statusCode == 200) {
    utils.customSnackBar('Role Mapping created successfully');
  }
  else {
    utils.customSnackBar('Role Mapping creation failed');
  }
}

// Update
Future<void> updateRoleMapping(BusinessUnitRoleMapModel roleMapping) async {
  var uri = Uri.parse(Uri.encodeFull(api.businessUnitRoleMappingUpdateReqStr));
  final http.Response res = await global.api.put(
    uri,
    headers: <String, String>{
      'Content-Type'   : 'application/json; charset=UTF-8',
      'x-access-token' : global.accessToken,
    },
    body: jsonEncode(roleMapping),
  );

  if (res.statusCode == 200) {
    utils.customSnackBar('Role Mapping updated successfully');
  }
  else {
    utils.customSnackBar('Role Mapping update failed');
  }
}

// Delete
Future<void> deleteRoleMapping(BusinessUnitRoleMapModel roleMapping) async {
  var uri = Uri.parse(Uri.encodeFull(api.businessUnitRoleMappingDeleteReqStr));
  final http.Response res = await global.api.delete(
    uri,
    headers: <String, String>{
      'Content-Type'   : 'application/json; charset=UTF-8',
      'x-access-token' : global.accessToken,
    },
    body: jsonEncode(roleMapping),
  );

  if (res.statusCode == 200) {
    utils.customSnackBar('Role Mapping deleted successfully');
  }
  else {
    utils.customSnackBar('Role Mapping delete failed');
  }
}



// Retrieve
Future<List<BusinessUnitRoleMapModel>> getAppRoleUserList(String businessUnitId,String applicationRoleId,String employeeId) async {
  List<BusinessUnitRoleMapModel> list = [];

  var uri = Uri.parse(Uri.encodeFull('${api.businessUnitRoleMappingAppRoleUserListReqStr}/${global.orgId}/$businessUnitId/$applicationRoleId/$employeeId'));
  final http.Response res = await global.api.get(
    uri,
    headers: <String, String>{
      'Accept'         : 'application/json',
      'x-access-token' : global.accessToken,
    },
  );

  var resBody = jsonDecode(res.body);

  if (resBody != null && resBody.isNotEmpty) {
    for (int i = 0; i < resBody.length; ++i) {
      list.add(BusinessUnitRoleMapModel.fromJson(resBody[i]));
    }
  }

  return list;
}


// Retrieve
Future<List<BusinessUnitRoleMapModel>> getAppRoleAllUserList(String businessUnitId,String applicationRoleId) async {
  List<BusinessUnitRoleMapModel> list = [];

  var uri = Uri.parse(Uri.encodeFull('${api.businessUnitRoleMappingAppRoleAllUserListReqStr}/${global.orgId}/$businessUnitId/$applicationRoleId'));
  print(uri);
  final http.Response res = await global.api.get(
    uri,
    headers: <String, String>{
      'Accept'         : 'application/json',
      'x-access-token' : global.accessToken,
    },
  );

  var resBody = jsonDecode(res.body);

  if (resBody != null && resBody.isNotEmpty) {
    for (int i = 0; i < resBody.length; ++i) {
      list.add(BusinessUnitRoleMapModel.fromJson(resBody[i]));
    }
  }

  return list;
}


// Retrieve
Future<List<BusinessUnitRoleMapModel>> getBusinessUnitListUsingEmp() async {
  List<BusinessUnitRoleMapModel> list = [];

  var uri = Uri.parse(Uri.encodeFull('${api.getBusinessUnitListUsingEmp}/${global.orgId}/${global.applicationId}/${global.employeeId}'));
  print(uri);
  final http.Response res = await global.api.get(
    uri,
    headers: <String, String>{
      'Accept'         : 'application/json',
      'x-access-token' : global.accessToken,
    },
  );

  var resBody = jsonDecode(res.body);

  if (resBody != null && resBody.isNotEmpty) {
    for (int i = 0; i < resBody.length; ++i) {
      list.add(BusinessUnitRoleMapModel.fromJson(resBody[i]));
    }
  }

  return list;
}


// Retrieve
Future<List<BusinessUnitRoleMapModel>> getBusinessUnitUsingListMailId() async {
  List<BusinessUnitRoleMapModel> list = [];

  var uri = Uri.parse(Uri.encodeFull('${api.getBusinessUnitUsingListMailId}/${global.orgId}/${global.applicationId}/${global.emailId}'));
  final http.Response res = await global.api.get(
    uri,
    headers: <String, String>{
      'Accept'         : 'application/json',
      'x-access-token' : global.accessToken,
    },
  );

  var resBody = jsonDecode(res.body);

  if (resBody != null && resBody.isNotEmpty) {
    for (int i = 0; i < resBody.length; ++i) {
      list.add(BusinessUnitRoleMapModel.fromJson(resBody[i]));
    }
  }

  return list;
}

