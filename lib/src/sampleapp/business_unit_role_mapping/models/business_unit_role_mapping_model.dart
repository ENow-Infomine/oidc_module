class BusinessUnitRoleMapModel {
  final String organizationId;
  String applicationId;
  String businessUnitId;
  String applicationRoleId;
  String employeeId;
  String officialEmailId;
  String? updatedBy;
  final DateTime? updatedAt;
  int? id;

  BusinessUnitRoleMapModel({
    required this.organizationId,
    required this.applicationId,
    required this.businessUnitId,
    required this.applicationRoleId,
    required this.employeeId,
    required this.officialEmailId,
    this.updatedBy,
    this.updatedAt,
    this.id,
  });

  factory BusinessUnitRoleMapModel.fromJson(Map<String, dynamic> json) {
    return BusinessUnitRoleMapModel(
      organizationId          : json['organizationId'],
      applicationId           : json['applicationId'],
      businessUnitId          : json['businessUnitId'],
      applicationRoleId       : json['applicationRoleId'],
      employeeId              : json['employeeId'],
      officialEmailId         : json['officialEmailId'],
      updatedBy               : json['updatedBy'],
      updatedAt               : DateTime.tryParse(json['updatedAt'] ?? ''),
      id                      : json['id'] ?? 0,
    );
  }

  toJson() {
    return <String, dynamic>{
      'organizationId'          : organizationId,
      'applicationId'           : applicationId,
      'businessUnitId'          : businessUnitId,
      'applicationRoleId'       : applicationRoleId,
      'employeeId'              : employeeId,
      'officialEmailId'         : officialEmailId,
      'updatedBy'               : updatedBy,
    };
  }
}