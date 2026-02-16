import 'package:data_table_2/data_table_2.dart';
import 'package:enow/risk/business_unit/models/business_unit_model.dart';
import 'package:enow/risk/business_unit/service/business_unit_service.dart';
import 'package:enow/risk/business_unit_role_mapping/models/business_unit_role_mapping_model.dart';
import 'package:enow/risk/business_unit_role_mapping/service/business_unit_role_mapping_service.dart';
import 'package:enow/shared/navigation_elements/risk_app_admin_navigation_drawer.dart';
import 'package:enow/shared/widgets/button_elements.dart';
import 'package:enow/shared/widgets/custom_alert_dialog.dart';
import 'package:enow/shared/widgets/custom_dropdown_form_field.dart';
import 'package:enow/shared/widgets/custom_text_form_field.dart';
import 'package:enow/shared/navigation_elements/header.dart';
import 'package:enow/users/models/organization_user_model.dart';
import 'package:enow/users/services/organization_user_services.dart';
import 'package:enow/workspace/models/application_role_member_model.dart';
import 'package:enow/workspace/models/application_role_model.dart';
import 'package:enow/workspace/services/application_role_member_services.dart';
import 'package:enow/workspace/services/application_role_services.dart';
import 'package:flutter/material.dart';
import 'package:enow/shared/styling.dart' as styling;
import 'package:enow/shared/utils.dart' as utils;
import 'package:enow/shared/global.dart' as global;

class BusinessUnitRoleMapping extends StatefulWidget {
  const BusinessUnitRoleMapping({super.key});
  @override
  State<BusinessUnitRoleMapping> createState() => _BusinessUnitRoleMappingState();
}

class _BusinessUnitRoleMappingState extends State<BusinessUnitRoleMapping> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormFieldState> unitFilterKey       = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> divisionFilterKey   = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> businessUnitFilterKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> appRoleFilterKey      = GlobalKey<FormFieldState>();

  String selectedBusinessUnitFilter = '';
  String selectedAppRoleFilter      = '';

  clearFilters() {
    businessUnitFilterKey.currentState!.reset();
    appRoleFilterKey.currentState!.reset();
    selectedBusinessUnitFilter = '';
    selectedAppRoleFilter      = '';
  }

  List<BusinessUnit> functionList        = [];

  List<OrgUser> userList              = [];
  List<ApplicationRole> appRoleList   = [];
  List<BusinessUnitRoleMapModel> assignedMembers = [];
  List<ApplicationRoleMember> appRoleMemList     = [];
  List<TextEditingController> businessUnitIdControllers          = [];
  List<TextEditingController> businessUnitDescriptionControllers = [];
  int counter = 0;

  void loadInitialData() async {

        var list1   = await getOrgUserList(global.orgId);
        var list2;
    for (int i = 0; i < list1.length; ++i) {
      list2 = await getAppRoleUserList(selectedBusinessUnitFilter,selectedAppRoleFilter,list1[i].employeeId);
      if(list2.isNotEmpty){
        list1.removeWhere((orgUser) => list2.last.employeeId == orgUser.employeeId);
      }
    }

    setState(() {
    userList = list1;
    //assignedMembers = list2;
    });
  }

  void emptyLoad() async {
    var list1 = await getAppRoleAllUserList(selectedBusinessUnitFilter,selectedAppRoleFilter);

    setState(() {
      assignedMembers = list1;
    });
  }

  void loadData() async {

    functionList = await getOrgBusinessUnitList();
    appRoleList    = await getRoleListUnderApplication(global.orgId,global.applicationId);
    var list1   = await getOrgUserList(global.orgId);
    setState(() {
      userList = list1;
    });
  }


  String getUserName(String userId) {
    for (int i = 0; i < userList.length; ++i) {
      if (userList[i].employeeId == userId) {
        return userList[i].firstName;
      }
    }

    return '';
  }

  clearFormControllers() {
    for (var element in businessUnitIdControllers) {
      element.dispose();
    }

    for (var element in businessUnitDescriptionControllers) {
      element.dispose();
    }

    businessUnitIdControllers.clear();
    businessUnitDescriptionControllers.clear();
  }



  Future<void> assignedMemberData() async {
    // Start fetching data concurrently
    var list1Future = getApplicationRoleMemberListUnderAppRole(global.orgId, global.applicationId, selectedAppRoleFilter);
    var list2Future = getAppRoleAllUserList(selectedBusinessUnitFilter, selectedAppRoleFilter);
    var list3Future = getOrgUserList(global.orgId);

    // Wait for all futures to complete
    var results = await Future.wait([list1Future, list2Future, list3Future]);
    var list1;
    var list2;
    var list3;

    list1 = results[0]; // Result from getApplicationRoleMemberListUnderAppRole
    list2 = results[1]; // Result from getAppRoleAllUser List
    list3 = results[2]; // Result from getOrgUser List

    setState(() {
      appRoleMemList  = list1;
      assignedMembers = list2;
      userList        = list3;

      final filteredUserList = userList.where((user) =>
      !assignedMembers.any((assigned) => assigned.employeeId == user.employeeId)).toList();

      userList = filteredUserList;
      print(userList.length);
    });
  }

  /*
  Future<void> assignedLoadData() async {
    // Start fetching data concurrently
    var list1Future = getApplicationRoleMemberListUnderAppRole(global.orgId, global.applicationId, selectedAppRoleFilter);
    var list2Future = getAppRoleAllUserList(selectedBusinessUnitFilter, selectedAppRoleFilter);
    var list3Future = getOrgUserList(global.orgId);

    // Wait for all futures to complete
    var results = await Future.wait([list1Future, list2Future, list3Future]);
    var list1;
    var list2;
    var list3;

     list1 = results[0]; // Result from getApplicationRoleMemberListUnderAppRole
     list2 = results[1]; // Result from getAppRoleAllUser List
     list3 = results[2]; // Result from getOrgUser List

    // Process list3 to remove users based on list4
    List<Future<void>> removalFutures = [];
    for (var orgUser  in list3) {
      removalFutures.add(
          getAppRoleUserList(selectedBusinessUnitFilter, selectedAppRoleFilter, orgUser.employeeId).then((list4) {
        if (list4.isNotEmpty) {
          list3.removeWhere((user) => list4.last.employeeId == user.employeeId);
        }
      }),
    );
    }

    // Wait for all removal operations to complete
    await Future.wait(removalFutures);

    // Update the state with the fetched data
    setState(() {
    appRoleMemList  = list1;
    assignedMembers = list2;
    userList        = list3;
    print(userList.length);
    });
  }

   */

  @override
  void initState() {
    super.initState();
    //loadInitialData();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    clearFormControllers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        //drawer: const RiskAppAdminNavigationDrawer(screenIndex: 2),

        body: Column(
          children: [
            //Header(screenTitle: 'Business Unit Role Mapping', scaffoldKey: scaffoldKey,),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //const RiskAppAdminNavigationDrawer(screenIndex: 2),

                  Expanded(
                    child: Padding(
                      padding: styling.kDefaultPadding,
                      child: Column(
                        children: [
                          Row(
                            children: [


                              Expanded(
                                child: CustomDropdownField(
                                  dropdownKey: businessUnitFilterKey,
                                  hideLabel: true,
                                  label: 'Business Unit / Function',
                                  items: functionList.map((item) {
                                    return DropdownMenuItem(
                                      value: item.businessUnitId,
                                      child: Text(item.businessUnitDescription),
                                    );
                                  }).toList(),
                                  onChanged: (String? val) {

                                    setState(() {
                                      selectedBusinessUnitFilter = val ?? '';
                                    });
                                  },
                                ),
                              ),


                              utils.kHGap(),


                              Expanded(
                                child: CustomDropdownField(
                                  dropdownKey: appRoleFilterKey,
                                  hideLabel: true,
                                  label: 'Roles',
                                  items: appRoleList.map((item) {
                                    return DropdownMenuItem(
                                      value: item.applicationRoleId,
                                      child: Text(item.applicationRoleDesc),
                                    );
                                  }).toList(),
                                  onChanged:  (String? val) async {
                                    selectedAppRoleFilter = val ?? '';
                                    //assignedLoadData();
                                    assignedMemberData();

                                    /*
                                    var list1 = await getApplicationRoleMemberListUnderAppRole(global.orgId,global.applicationId,val!);

                                    var list2 = await getAppRoleAllUserList(selectedBusinessUnitFilter,selectedAppRoleFilter);

                                    var list3 = await getOrgUserList(global.orgId);

                                    for (int i = 0; i < list3.length; ++i) {
                                      var list4 = await getAppRoleUserList(selectedBusinessUnitFilter,selectedAppRoleFilter,list3[i].employeeId);
                                      if(list4.isNotEmpty){
                                        list3.removeWhere((orgUser) => list4.last.employeeId == orgUser.employeeId);
                                      }
                                    }

                                    setState(() {
                                      appRoleMemList  = list1;
                                      assignedMembers = list2;
                                      userList        = list3;
                                      //loadInitialData();
                                      print(userList.length);
                                    });

                                     */
                                  },
                                ),
                              ),

                              utils.kHGap(),

                              SquareFilledButton(
                                onPressed: () {
                                  clearFilters();
                                  loadData();
                                },
                                iconData: Icons.refresh,
                              ),

                            ],
                          ),

                          utils.kVLargeGap(),

                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('AVAILABLE MEMBERS',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.black),
                                        ),
                                        child: ListView.builder(
                                          itemCount: userList.length,
                                          itemBuilder: (context, index) {
                                            final member = userList[index];
                                            return FutureBuilder(
                                              future: getOffMailUserDetails(global.orgId, member.officialEmail),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return ListTile(
                                                    title: Text(
                                                        '${member.employeeId} - Loading...'),
                                                    trailing: const Icon(Icons.add_circle,
                                                        color: Colors.green),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return ListTile(
                                                    title: Text(
                                                        '${member.employeeId} - Error loading name'),
                                                    trailing: const Icon(Icons.add_circle,
                                                        color: Colors.green),
                                                  );
                                                } else if (snapshot.hasData) {
                                                  var user = snapshot.data;
                                                  String fullName = '';
                                                  if (user != null) {

                                                    //fullName = '${user.firstName ?? ''} ${user.middleName ?? ''} ${user.lastName ?? ''}'.trim();
                                                  }
                                                  return ListTile(
                                                    title:
                                                    Text('${member.employeeId} - ${member.officialEmail}'), //Text('${member.empId} - $fullName')
                                                    trailing: const Icon(Icons.add_circle,
                                                        color: Colors.green),
                                                    onTap: () async {
                                                      counter++;

                                                      BusinessUnitRoleMapModel function = BusinessUnitRoleMapModel(
                                                        organizationId          : global.orgId,
                                                        applicationId           : global.applicationId,
                                                        businessUnitId          : selectedBusinessUnitFilter,
                                                        applicationRoleId       : selectedAppRoleFilter,
                                                        employeeId              : member.employeeId,
                                                        officialEmailId         : member.officialEmail,
                                                        updatedBy               : global.userId,
                                                        id                      : counter,
                                                      );

                                                      if (!appRoleMemList.any((m) => m.empId == member.employeeId)) {
                                                        appRoleMemList.clear();
                                                        appRoleMemList.add(ApplicationRoleMember(
                                                          orgId               : global.orgId,
                                                          applicationId       : global.applicationId,
                                                          applicationRoleId   : selectedAppRoleFilter,
                                                          roleId              : '',
                                                          empId               : member.employeeId,
                                                          officialEmailId     : member.officialEmail,
                                                          updatedBy           : global.loginId,
                                                          updatedDateTime     : DateTime.now(),
                                                          activeStatus        : 'y'
                                                        ));
                                                      }


                                                      setState(() {
                                                        assignedMembers.clear();
                                                        assignedMembers.add(function);
                                                        userList.removeWhere((orgUser) => orgUser.employeeId == assignedMembers.last.employeeId);
                                                      });
                                                      await createRoleMapping(assignedMembers);
                                                      for (int i = 0; i < appRoleMemList.length; ++i){
                                                        await createApplicationRoleMember(appRoleMemList[i]);
                                                      }

                                                      emptyLoad();
                                                    },
                                                  );
                                                } else {
                                                  return ListTile(
                                                    title: Text(
                                                        '${member.employeeId} - No data available'),
                                                    trailing: const Icon(Icons.add_circle,
                                                        color: Colors.green),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('ASSIGNED MEMBERS',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.black),
                                        ),
                                        child: ListView.builder(
                                          itemCount: assignedMembers.length,
                                          itemBuilder: (context, index) {
                                            final member = assignedMembers[index];
                                            return FutureBuilder(
                                              future: getOffMailUserDetails(global.orgId, member.officialEmailId), // Assuming email can fetch user details
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return ListTile(
                                                    title: Text('${member.officialEmailId} - Loading...'),
                                                    trailing: const Icon(Icons.remove_circle,
                                                        color: Colors.red),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return ListTile(
                                                    title: Text('${member.officialEmailId} - Error loading name'),
                                                    trailing: const Icon(Icons.remove_circle,
                                                        color: Colors.red),
                                                  );
                                                } else if (snapshot.hasData) {
                                                  var user = snapshot.data;
                                                  String fullName = '';
                                                  if (user != null) {
                                                    //fullName = '${user.firstName ?? ''} ${user.middleName ?? ''} ${user.lastName ?? ''}'.trim();
                                                  }
                                                  return ListTile(
                                                    title: Text('${member.employeeId} - ${member.officialEmailId}'), //Text('${member.officialEmailId} - $fullName')
                                                    trailing: const Icon(Icons.remove_circle,
                                                        color: Colors.red),
                                                    onTap: () async {
                                                      print(member.officialEmailId);

                                                      var list1 = await getAppRoleUserList(selectedBusinessUnitFilter,selectedAppRoleFilter,member.employeeId);

                                                      print('${list1.length}');
                                                      if(list1.isNotEmpty){
                                                        await deleteRoleMapping(BusinessUnitRoleMapModel(
                                                          organizationId          : global.orgId,
                                                          applicationId           : global.applicationId,
                                                          businessUnitId          : selectedBusinessUnitFilter,
                                                          applicationRoleId       : selectedAppRoleFilter,
                                                          employeeId              : member.employeeId,
                                                          officialEmailId         : member.officialEmailId,
                                                          updatedBy               : global.userId,
                                                        ));
                                                      }

                                                      setState(()  {
                                                        if (!appRoleMemList.any((m) => m.empId == member.employeeId)) {
                                                          appRoleMemList.clear();
                                                          appRoleMemList.add(ApplicationRoleMember(
                                                              orgId               : global.orgId,
                                                              applicationId       : global.applicationId,
                                                              applicationRoleId   : selectedAppRoleFilter,
                                                              roleId              : '',
                                                              empId               : member.employeeId,
                                                              officialEmailId     : member.officialEmailId,
                                                              updatedBy           : global.loginId,
                                                              updatedDateTime     : DateTime.now(),
                                                              activeStatus        : 'N'
                                                          ));
                                                        }
                                                        //assignedMembers.removeAt(index);
                                                        loadInitialData();
                                                        assignedMembers.removeWhere((roleUser) => roleUser.employeeId == member.employeeId);
                                                      });

                                                      for (int i = 0; i < appRoleMemList.length; ++i){
                                                        await deleteApplicationRoleMember(appRoleMemList[i]);
                                                      }



                                                    },
                                                  );
                                                } else {
                                                  return ListTile(
                                                    title: Text(
                                                        '${member.officialEmailId} - No data available'),
                                                    trailing: const Icon(Icons.remove_circle,
                                                        color: Colors.red),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}