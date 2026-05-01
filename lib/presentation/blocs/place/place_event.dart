part of 'place_bloc.dart';

sealed class PlaceEvent extends Equatable {
  const PlaceEvent();
}

final class FetchPlaces extends PlaceEvent {
  final String categoryCode;
  final double x;
  final double y;

  const FetchPlaces({
    required this.categoryCode,
    required this.x,
    required this.y,
  });

  @override
  List<Object> get props => [categoryCode, x, y];
}

final class PickRandomPlace extends PlaceEvent {
  const PickRandomPlace();

  @override
  List<Object> get props => [];
}
