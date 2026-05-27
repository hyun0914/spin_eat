import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/kakao_categories.dart';
import '../../../data/models/place_model.dart';
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
  List<PlaceModel> placeHistory = [];

  static const _primary = Color(0xFFFF5722);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF888888);

  void storeInfo(PlaceModel selectedPlace) {
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
              selectedPlace.placeName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedPlace.categoryName,
              style: const TextStyle(
                fontSize: 13,
                color: _primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: (selectedPlace.roadAddressName as String? ?? '').isNotEmpty
                  ? selectedPlace.roadAddressName
                  : selectedPlace.addressName,
            ),
            if ((selectedPlace.phone as String? ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.phone_outlined,
                text: selectedPlace.phone,
              ),
            ],
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.near_me_outlined,
              text: '${selectedPlace.distance}m 거리',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    launchUrl(Uri.parse(selectedPlace.placeUrl)),
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
        strokeWidth: 2,
        strokeColor: _primary,
        strokeOpacity: 0.6,
        strokeStyle: StrokeStyle.solid,
        fillColor: _primary,
        fillOpacity: 0.08,
        radius: radius.toDouble(),
      ),
    ]);
  }

  void _clearHistory() {
    setState(() {
      mapController?.clearMarker();
      mapController?.clearPolyline();
      placeHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, locationState) {
        if (locationState is LocationUpdate) {
          _updateCircle(locationState.latitude,
              locationState.longitude);
          mapController?.setCenter(LatLng(locationState.latitude, locationState.longitude));
        }
      },
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

        if (locationState is LocationWithData) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
              body: Stack(
                children: [
                  KakaoMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                      mapController?.addCircle(circles: [
                        Circle(
                          circleId: '0',
                          center: LatLng(locationState.latitude, locationState.longitude),
                          strokeWidth: 2,
                          strokeColor: _primary,
                          strokeOpacity: 0.6,
                          strokeStyle: StrokeStyle.solid,
                          fillColor: _primary,
                          fillOpacity: 0.08,
                          radius: radius.toDouble(),
                        ),
                      ]);
                    },
                    onMarkerTap: (markerId, latLng, zoomLevel) {
                      final state = context.read<PlaceBloc>().state;
                      if (state is PlaceLoaded && state.selectedPlace != null) {
                        storeInfo(state.selectedPlace!);
                      }
                    },
                    center: LatLng(
                        locationState.latitude, locationState.longitude),
                  ),

                  // Floating brand pill
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          context.read<LocationBloc>().add(GetLocation());
                        },
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
                          // Drag handle
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // History section header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '히스토리',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (placeHistory.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${placeHistory.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (placeHistory.isNotEmpty)
                                GestureDetector(
                                  onTap: _clearHistory,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.refresh_rounded,
                                            size: 13, color: _textMuted),
                                        SizedBox(width: 4),
                                        Text(
                                          '초기화',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Radius section
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _RadiusChip(
                                label: '300m',
                                selected: radius == 300,
                                onTap: () => setState(() {
                                  radius = 300;
                                  _updateCircle(locationState.latitude,
                                      locationState.longitude);
                                }),
                              ),
                              const SizedBox(width: 8),
                              _RadiusChip(
                                label: '500m',
                                selected: radius == 500,
                                onTap: () => setState(() {
                                  radius = 500;
                                  _updateCircle(locationState.latitude,
                                      locationState.longitude);
                                }),
                              ),
                              const SizedBox(width: 8),
                              _RadiusChip(
                                label: '1km',
                                selected: radius == 1000,
                                onTap: () => setState(() {
                                  radius = 1000;
                                  _updateCircle(locationState.latitude,
                                      locationState.longitude);
                                }),
                              ),
                              const SizedBox(width: 8),
                              _RadiusChip(
                                label: '2km',
                                selected: radius == 2000,
                                onTap: () => setState(() {
                                  radius = 2000;
                                  _updateCircle(locationState.latitude,
                                      locationState.longitude);
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Category section
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
                          const SizedBox(height: 8),
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
                              const SizedBox(width: 8),
                              _CategoryChip(
                                label: '대형마트',
                                icon: Icons.shopping_cart,
                                selected: categoryCode ==
                                    KakaoCategories.mart,
                                onTap: () => setState(() =>
                                categoryCode = KakaoCategories.mart),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Spin button
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
                                storeInfo(state.selectedPlace!);
                                if (!placeHistory.any((p) =>
                                    p.id == state.selectedPlace!.id)) {
                                  setState(() {
                                    placeHistory.add(state.selectedPlace!);
                                  });
                                }

                                mapController?.addMarker(
                                  markers: placeHistory
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    return Marker(
                                      markerId: 'marker_${entry.key}',
                                      latLng: LatLng(
                                        double.parse(entry.value.y),
                                        double.parse(entry.value.x),
                                      ),
                                    );
                                  }).toList(),
                                );

                                if (placeHistory.length > 1) {
                                  mapController?.clearPolyline();
                                  mapController?.addPolyline(
                                    polylines: [
                                      Polyline(
                                        polylineId:
                                            'polyline_${placeHistory.length}',
                                        points: placeHistory.map((entry) {
                                          return LatLng(
                                            double.parse(entry.y),
                                            double.parse(entry.x),
                                          );
                                        }).toList(),
                                        strokeColor: _primary,
                                        strokeWidth: 4,
                                      )
                                    ],
                                  );
                                }
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
                                          if (locState is LocationWithData) {
                                            context
                                                .read<PlaceBloc>()
                                                .add(FetchPlaces(
                                                  categoryCode: categoryCode,
                                                  x: locState.longitude,
                                                  y: locState.latitude,
                                                  radius: radius,
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
                                      borderRadius: BorderRadius.circular(14),
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

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? _primary : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF888888),
              ),
            ),
          ),
        ),
      ),
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
                  color: selected ? Colors.white : const Color(0xFF888888),
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
