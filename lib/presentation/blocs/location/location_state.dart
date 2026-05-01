part of 'location_bloc.dart';

sealed class LocationState extends Equatable {
  const LocationState();
}

final class LocationInitial extends LocationState {
  const LocationInitial();

  @override
  List<Object> get props => [];
}

final class LocationLoading extends LocationState {
  const LocationLoading();

  @override
  List<Object> get props => [];
}

final class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;

  const LocationLoaded({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

final class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object> get props => [message];
}