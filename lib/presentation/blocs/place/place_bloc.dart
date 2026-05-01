import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repositories/place_repository.dart';

part 'place_event.dart';
part 'place_state.dart';

class PlaceBloc extends Bloc<PlaceEvent, PlaceState> {
  final PlaceRepository placeRepository;

  PlaceBloc({required this.placeRepository}) : super(const PlaceInitial()) {
    on<FetchPlaces>(_onFetchPlaces);
    on<PickRandomPlace>(_onPickRandomPlace);
  }

  Future<void> _onFetchPlaces(
      FetchPlaces event,
      Emitter<PlaceState> emit,
      ) async {
    emit(const PlaceLoading());
    try {
      final places = await placeRepository.searchByCategory(
        categoryCode: event.categoryCode,
        x: event.x,
        y: event.y,
      );
      emit(PlaceLoaded(places: places));
    } catch (e) {
      emit(PlaceError(message: e.toString()));
    }
  }

  void _onPickRandomPlace(
      PickRandomPlace event,
      Emitter<PlaceState> emit,
      ) {
    if (state is PlaceLoaded) {
      final current = state as PlaceLoaded;
      final shuffled = List.from(current.places)..shuffle();
      emit(PlaceLoaded(
        places: current.places,
        selectedPlace: shuffled.first,
      ));
    }
  }
}