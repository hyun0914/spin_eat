import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repositories/location_repository.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository locationRepository;

  LocationBloc({required this.locationRepository}) : super(LocationInitial()) {
    on<GetLocation>(_onGetLocation);
  }
  void _onGetLocation(
      GetLocation event,
      Emitter<LocationState> emit,
      ) async {
    emit(const LocationLoading());
    try {
      final location = await locationRepository.getCurrentPosition();

      emit(LocationLoaded(latitude: location.latitude, longitude: location.longitude));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }
}
