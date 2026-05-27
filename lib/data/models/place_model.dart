class PlaceModel {
  final String placeName;
  final String distance;
  final String placeUrl;
  final String categoryName;
  final String addressName;
  final String roadAddressName;
  final String id;
  final String phone;
  final String categoryGroupCode;
  final String categoryGroupName;
  final String x;
  final String y;

  const PlaceModel({
    required this.placeName,
    required this.distance,
    required this.placeUrl,
    required this.categoryName,
    required this.addressName,
    required this.roadAddressName,
    required this.id,
    required this.phone,
    required this.categoryGroupCode,
    required this.categoryGroupName,
    required this.x,
    required this.y,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      placeName: json['place_name'] ?? '',
      distance: json['distance'] ?? '',
      placeUrl: json['place_url'] ?? '',
      categoryName: json['category_name'] ?? '',
      addressName:  json['address_name'] ?? '',
      roadAddressName: json['road_address_name'] ?? '',
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      categoryGroupCode: json['category_group_code'] ?? '',
      categoryGroupName: json['category_group_name'] ?? '',
      x: json['x'] ?? '0',
      y: json['y'] ?? '0',
    );
  }
}