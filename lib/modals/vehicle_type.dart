class VechicalType {
  bool? success;
  String? message;
  List<Data>? data;

  VechicalType({this.success, this.message, this.data});

  VechicalType.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  Null? companyKey;
  String? ownerId;
  String? name;
  String? icon;
  String? iconTypesFor;
  String? tripDispatchType;
  int? capacity;
  String? modelName;
  String? size;
  String? description;
  String? shortDescription;
  String? supportedVehicles;
  int? isAcceptShareRide;
  int? active;
  int? smoking;
  int? pets;
  int? drinking;
  int? handicaped;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;
  String? isTaxi;

  Data(
      {this.id,
        this.companyKey,
        this.ownerId,
        this.name,
        this.icon,
        this.iconTypesFor,
        this.tripDispatchType,
        this.capacity,
        this.modelName,
        this.size,
        this.description,
        this.shortDescription,
        this.supportedVehicles,
        this.isAcceptShareRide,
        this.active,
        this.smoking,
        this.pets,
        this.drinking,
        this.handicaped,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.isTaxi});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyKey = json['company_key'];
    ownerId = json['owner_id'];
    name = json['name'];
    icon = json['icon'];
    iconTypesFor = json['icon_types_for'];
    tripDispatchType = json['trip_dispatch_type'];
    capacity = json['capacity'];
    modelName = json['model_name'];
    size = json['size'];
    description = json['description'];
    shortDescription = json['short_description'];
    supportedVehicles = json['supported_vehicles'];
    isAcceptShareRide = json['is_accept_share_ride'];
    active = json['active'];
    smoking = json['smoking'];
    pets = json['pets'];
    drinking = json['drinking'];
    handicaped = json['handicaped'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    isTaxi = json['is_taxi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_key'] = this.companyKey;
    data['owner_id'] = this.ownerId;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['icon_types_for'] = this.iconTypesFor;
    data['trip_dispatch_type'] = this.tripDispatchType;
    data['capacity'] = this.capacity;
    data['model_name'] = this.modelName;
    data['size'] = this.size;
    data['description'] = this.description;
    data['short_description'] = this.shortDescription;
    data['supported_vehicles'] = this.supportedVehicles;
    data['is_accept_share_ride'] = this.isAcceptShareRide;
    data['active'] = this.active;
    data['smoking'] = this.smoking;
    data['pets'] = this.pets;
    data['drinking'] = this.drinking;
    data['handicaped'] = this.handicaped;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['is_taxi'] = this.isTaxi;
    return data;
  }
}
