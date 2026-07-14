import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../network/network_info.dart';

/// This is where we set up all the shared objects the app needs, one time,
/// before the app starts. Screens and blocs just ask for what they need
/// instead of building it themselves.
final GetIt sl = GetIt.instance;

// Call this once from main(), before runApp().
Future<void> initDependencies() async {
  await _initCore();
}

Future<void> _initCore() async {
  sl.registerLazySingleton(Connectivity.new);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
