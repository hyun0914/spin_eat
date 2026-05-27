part of 'place_bloc.dart';

sealed class PlaceState extends Equatable {
  const PlaceState();
}

final class PlaceInitial extends PlaceState {
  const PlaceInitial();

  @override
  List<Object> get props => [];
}

final class PlaceLoading extends PlaceState {
  const PlaceLoading();

  @override
  List<Object> get props => [];
}

final class PlaceLoaded extends PlaceState {
  final List<PlaceModel> places;
  final PlaceModel? selectedPlace;

  const PlaceLoaded({
    required this.places,
    this.selectedPlace,
  });

  @override
  List<Object> get props => [places, selectedPlace ?? ''];
}

final class PlaceError extends PlaceState {
  final String message;

  const PlaceError({required this.message});

  @override
  List<Object> get props => [message];
}
