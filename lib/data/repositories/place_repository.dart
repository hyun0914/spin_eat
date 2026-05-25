import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';

class PlaceRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://dapi.kakao.com',
    headers: {'Authorization': 'KakaoAK ${AppConfig.kakaoRestKey}'},
  ));

  Future<List<dynamic>> searchByCategory({
    required String categoryCode,
    required double x,
    required double y,
    required int radius,
  }) async {
    final response = await _dio.get(
      '/v2/local/search/category.json',
      queryParameters: {
        'category_group_code': categoryCode,
        'x': x,
        'y': y,
        'radius': radius,
        'sort': 'distance',
      },
    );
    return response.data['documents'];
  }
}