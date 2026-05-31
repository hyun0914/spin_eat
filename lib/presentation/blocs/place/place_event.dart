part of 'place_bloc.dart';

sealed class PlaceEvent extends Equatable {
  const PlaceEvent();
}

final class FetchPlaces extends PlaceEvent {
  final String categoryCode;
  final double x;
  final double y;
  final int radius;

  const FetchPlaces({
    required this.categoryCode,
    required this.x,
    required this.y,
    required this.radius,
  });

  @override
  List<Object> get props => [categoryCode, x, y];
}

final class PickRandomPlace extends PlaceEvent {
  const PickRandomPlace();

  @override
  List<Object> get props => [];
}

final class SelectPlace extends PlaceEvent {
  final PlaceModel place;

  const SelectPlace(this.place);

  @override
  List<Object> get props => [place];
}
