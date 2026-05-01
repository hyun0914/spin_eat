import 'package:geolocator/geolocator.dart';

class LocationRepository {
  Future<Position> getCurrentPosition() async {
    // 위치 서비스 활성화 여부 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }

    // 위치 권한 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    // 위치 권한 영구 거부 확인
    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }

    // 현재 위치 반환
    return await Geolocator.getCurrentPosition();
  }
}