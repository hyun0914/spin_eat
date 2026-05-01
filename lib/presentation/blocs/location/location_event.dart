part of 'location_bloc.dart';

sealed class LocationEvent extends Equatable {
  const LocationEvent();
}

final class GetLocation extends LocationEvent {
  const GetLocation();

  @override
  List<Object?> get props => [];
}