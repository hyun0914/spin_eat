import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/kakao_categories.dart';
import '../../blocs/location/location_bloc.dart';
import '../../blocs/place/place_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  KakaoMapController? mapController;
  Set<Marker> markers = {};
  String categoryCode = '';

  void storeInfo(Map<String, dynamic>? selectedPlace) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 700,
          color: Colors.blueGrey,
          child: Column(
            children: [
              Text(
                '가게 이름: ${selectedPlace?['place_name']}\n'
                '주소: ${selectedPlace?['address_name']}\n'
                '도로명 주소: ${selectedPlace?['road_address_name']}\n'
                '전화번호: ${selectedPlace?['phone']}\n'
                '거리 (미터): ${selectedPlace?['distance']}\n'
                '카테고리: ${selectedPlace?['category_name']}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green
                ),
              ),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(selectedPlace?['place_url'] ?? '')),
                child: Text(
                  '카카오맵에서 보기',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (locationState is LocationLoaded) {
          return Scaffold(
            appBar: AppBar(),
            body: KakaoMap(
              onMapCreated: ((controller) {
                mapController = controller;
              }),
              markers: markers.toList(),
              onMarkerTap: (markerId, latLng, zoomLevel) {
                final state = context.read<PlaceBloc>().state;
                if (state is PlaceLoaded && state.selectedPlace != null) {
                  storeInfo(state.selectedPlace);
                }
              },
              center: LatLng(locationState.latitude, locationState.longitude),
            ),
            bottomSheet: Container(
              width: double.infinity,
              height: 300,
              color: Colors.blueGrey,
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            categoryCode = KakaoCategories.restaurant;
                          });
                        },
                        child: Text(
                          '음식점',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            categoryCode = KakaoCategories.cafe;
                          });
                        },
                        child: Text(
                          '카페',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            categoryCode = KakaoCategories.convenience;
                          });
                        },
                        child: Text(
                          '편의점',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: categoryCode == ''?
                    null : () {
                      final state = context.read<LocationBloc>().state;
                      if (state is LocationLoaded) {
                        final loadedState = state;
                        context.read<PlaceBloc>().add(FetchPlaces(
                          categoryCode: categoryCode,
                          x: loadedState.longitude,
                          y: loadedState.latitude,
                        ));
                      }
                    },
                    child: Text(
                      '랜덤 가게 선택',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  BlocConsumer<PlaceBloc, PlaceState>(
                    listener: (context, state) {
                      // 1. FetchPlaces 완료 → 자동으로 PickRandomPlace 호출
                      if (state is PlaceLoaded && state.selectedPlace == null) {
                        context.read<PlaceBloc>().add(const PickRandomPlace());
                      }

                      // 2. PickRandomPlace 완료 → 핀 꽂기
                      if (state is PlaceLoaded && state.selectedPlace != null) {
                        mapController?.clearMarker(); // 기존 마커 제거
                        mapController?.addMarker(
                          markers: [
                            Marker(
                              markerId: 'selected',
                              latLng: LatLng(
                                double.parse(state.selectedPlace?['y'] ?? '0'),
                                double.parse(state.selectedPlace?['x'] ?? '0'),
                              ),
                            )
                          ],
                        );
                        storeInfo(state.selectedPlace);
                      }
                    },
                    builder: (context, state) {
                      if (state is PlaceLoading) return CircularProgressIndicator();
                      if (state is PlaceLoaded && state.selectedPlace != null) return Text(state.selectedPlace?['place_name'] ?? '');
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
