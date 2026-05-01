import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:spin_eat/presentation/blocs/place/place_bloc.dart';
import 'core/config/app_config.dart';
import 'data/repositories/location_repository.dart';
import 'data/repositories/place_repository.dart';
import 'presentation/blocs/location/location_bloc.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AuthRepository.initialize(appKey: AppConfig.kakaoJsKey);
  runApp(const SpinEatApp());
}

class SpinEatApp extends StatelessWidget {
  const SpinEatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LocationBloc(
            locationRepository: LocationRepository(),
          )..add(const GetLocation()),
        ),
        BlocProvider(
          create: (context) => PlaceBloc(
            placeRepository: PlaceRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}


