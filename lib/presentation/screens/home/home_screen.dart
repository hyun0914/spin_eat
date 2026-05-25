import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String categoryCode = '';
  int radius = 500;
  List<Map<String, dynamic>> placeHistory = [];

  static const _primary = Color(0xFFFF5722);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF888888);

  void storeInfo(Map<String, dynamic>? selectedPlace) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              selectedPlace?['place_name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedPlace?['category_name'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: _primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: (selectedPlace?['road_address_name'] as String? ?? '').isNotEmpty
                  ? selectedPlace!['road_address_name']
                  : selectedPlace?['address_name'] ?? '',
            ),
            if ((selectedPlace?['phone'] as String? ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.phone_outlined,
                text: selectedPlace?['phone'] ?? '',
              ),
            ],
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.near_me_outlined,
              text: '${selectedPlace?['distance']}m 거리',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    launchUrl(Uri.parse(selectedPlace?['place_url'] ?? '')),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('카카오맵에서 보기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCircle(double latitude, double longitude) {
    mapController?.clearCircle();
    mapController?.addCircle(circles: [
      Circle(
        circleId: '0',
        center: LatLng(latitude, longitude),
        strokeWidth: 5,
        strokeColor: Colors.red,
        strokeOpacity: 0.5,
        strokeStyle: StrokeStyle.longDashDotDot,
        fillColor: Colors.black,
        fillOpacity: 0.7,
        radius: radius.toDouble(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: _primary,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '위치를 가져오는 중...',
                    style: TextStyle(color: _textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        if (locationState is LocationLoaded) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
              body: Stack(
                children: [
                  KakaoMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                      mapController?.addCircle(circles: {
                        Circle(
                          circleId: '0',
                          center: LatLng(locationState.latitude, locationState.longitude),
                          strokeWidth: 5,
                          strokeColor: Colors.red,
                          strokeOpacity: 0.5,
                          strokeStyle: StrokeStyle.longDashDotDot,
                          fillColor: Colors.black,
                          fillOpacity: 0.7,
                          radius: radius.toDouble(),
                        ),
                      }.toList());
                    },
                    onMarkerTap: (markerId, latLng, zoomLevel) {
                      final state = context.read<PlaceBloc>().state;
                      if (state is PlaceLoaded && state.selectedPlace != null) {
                        storeInfo(state.selectedPlace);
                      }
                    },
                    center: LatLng(
                        locationState.latitude, locationState.longitude),
                  ),

                  // Floating brand pill
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Spin',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: _primary,
                              ),
                            ),
                            Text(
                              'Eat',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom control panel
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 24,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        MediaQuery.of(context).padding.bottom + 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: (){
                              if (placeHistory.isNotEmpty) {
                                mapController?.clearMarker();
                                mapController?.clearPolyline();
                                placeHistory.clear();
                              }
                            },
                            child: Text('초기화'),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '거리',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() {
                                radius = 300;
                                _updateCircle(locationState.latitude, locationState.longitude);
                                }),
                                child: Text('300m',),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() {
                                radius = 500;
                                _updateCircle(locationState.latitude, locationState.longitude);
                                }),
                                child: Text('500m',),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() {
                                radius = 1000;
                                _updateCircle(locationState.latitude, locationState.longitude);
                                }),
                                child: Text('1km',),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                radius = 2000;
                                _updateCircle(locationState.latitude, locationState.longitude);
                                }),
                                child: Text('2km',),
                              ),

                            ],
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '카테고리',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _CategoryChip(
                                label: '음식점',
                                icon: Icons.restaurant_rounded,
                                selected: categoryCode ==
                                    KakaoCategories.restaurant,
                                onTap: () => setState(() =>
                                    categoryCode = KakaoCategories.restaurant),
                              ),
                              const SizedBox(width: 8),
                              _CategoryChip(
                                label: '카페',
                                icon: Icons.local_cafe_rounded,
                                selected:
                                    categoryCode == KakaoCategories.cafe,
                                onTap: () => setState(
                                    () => categoryCode = KakaoCategories.cafe),
                              ),
                              const SizedBox(width: 8),
                              _CategoryChip(
                                label: '편의점',
                                icon: Icons.store_rounded,
                                selected: categoryCode ==
                                    KakaoCategories.convenience,
                                onTap: () => setState(() =>
                                    categoryCode = KakaoCategories.convenience),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          BlocConsumer<PlaceBloc, PlaceState>(
                            listener: (context, state) {
                              if (state is PlaceLoaded &&
                                  state.selectedPlace == null) {
                                context
                                    .read<PlaceBloc>()
                                    .add(const PickRandomPlace());
                              }
                              if (state is PlaceLoaded &&
                                  state.selectedPlace != null) {
                                storeInfo(state.selectedPlace);
                                if (!placeHistory.any((p) => p['id'] == state.selectedPlace!['id'])) {
                                  placeHistory.add(state.selectedPlace!);
                                }

                                mapController?.addMarker(
                                  markers: placeHistory.asMap().entries.map((entry) {
                                    return Marker(
                                      markerId: 'marker_${entry.key}',
                                      latLng: LatLng(
                                        double.parse(entry.value['y']),
                                        double.parse(entry.value['x']),
                                      ),
                                    );
                                  }).toList(),
                                );

                                mapController?.clearPolyline();
                                mapController?.addPolyline(
                                  polylines: [Polyline(
                                    polylineId: 'polyline_${placeHistory.length}',
                                    points: placeHistory.map((entry) {
                                      return LatLng(
                                        double.parse(entry['y']),
                                        double.parse(entry['x']),
                                      );
                                    }).toList(),
                                    strokeColor: Colors.purple,
                                    strokeWidth: 6,
                                  )],
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is PlaceLoading;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (categoryCode == '' || isLoading)
                                      ? null
                                      : () {
                                          final locState = context
                                              .read<LocationBloc>()
                                              .state;
                                          if (locState is LocationLoaded) {
                                            context
                                                .read<PlaceBloc>()
                                                .add(FetchPlaces(
                                                  categoryCode: categoryCode,
                                                  x: locState.longitude,
                                                  y: locState.latitude,
                                                  radius: radius
                                                ));
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFFE0E0E0),
                                    disabledForegroundColor: Colors.white54,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.shuffle_rounded,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text('랜덤 가게 선택'),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const _primary = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _primary : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : const Color(0xFF888888),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
