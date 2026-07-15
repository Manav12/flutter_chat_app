// This file connect all pieces of app together (data source, repo, use
// case, bloc), one time when app start.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/fake_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/domain/usecases/watch_auth_state_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/chat/data/datasources/chat_local_data_source.dart';
import '../../features/chat/data/datasources/chat_local_data_source_impl.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/datasources/fake_chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/delete_message_usecase.dart';
import '../../features/chat/domain/usecases/edit_message_usecase.dart';
import '../../features/chat/domain/usecases/send_image_message_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/watch_conversations_usecase.dart';
import '../../features/chat/domain/usecases/watch_messages_usecase.dart';
import '../../features/users/data/datasources/fake_user_remote_data_source.dart';
import '../../features/users/data/datasources/user_local_data_source.dart';
import '../../features/users/data/datasources/user_local_data_source_impl.dart';
import '../../features/users/data/datasources/user_remote_data_source.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/update_profile_usecase.dart';
import '../../features/users/domain/usecases/watch_all_users_usecase.dart';
import '../network/network_info.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initHive();
  await _initCore();
  _initAuth();
  _initUsers();
  _initChat();
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  final usersBox = await Hive.openBox<dynamic>('users_cache');
  final messagesBox = await Hive.openBox<dynamic>('messages_cache');
  sl
    ..registerLazySingleton<Box<dynamic>>(
      () => usersBox,
      instanceName: 'usersBox',
    )
    ..registerLazySingleton<Box<dynamic>>(
      () => messagesBox,
      instanceName: 'messagesBox',
    );
}

Future<void> _initCore() async {
  sl.registerLazySingleton(Connectivity.new);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}

void _initAuth() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      FakeAuthRemoteDataSource.new,
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerFactory(() => LoginUseCase(sl(), sl()))
    ..registerFactory(() => RegisterUseCase(sl(), sl()))
    ..registerFactory(() => LogoutUseCase(sl()))
    ..registerFactory(() => WatchAuthStateUseCase(sl(), sl()))
    ..registerFactory(() => UpdatePasswordUseCase(sl()))
    ..registerLazySingleton(
      () => AuthBloc(
        watchAuthState: sl(),
        login: sl(),
        register: sl(),
        logout: sl(),
        updateProfile: sl(),
        updatePassword: sl(),
      ),
    );
}

void _initUsers() {
  sl
    ..registerLazySingleton<UserRemoteDataSource>(
      FakeUserRemoteDataSource.new,
    )
    ..registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSourceImpl(sl(instanceName: 'usersBox')),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerFactory(() => WatchAllUsersUseCase(sl()))
    ..registerFactory(() => UpdateProfileUseCase(sl()));
}

void _initChat() {
  sl
    ..registerLazySingleton<ChatRemoteDataSource>(
      FakeChatRemoteDataSource.new,
    )
    ..registerLazySingleton<ChatLocalDataSource>(
      () => ChatLocalDataSourceImpl(sl(instanceName: 'messagesBox')),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
        userRepository: sl(),
      ),
    )
    ..registerFactory(() => SendMessageUseCase(sl()))
    ..registerFactory(() => SendImageMessageUseCase(sl()))
    ..registerFactory(() => WatchMessagesUseCase(sl()))
    ..registerFactory(() => EditMessageUseCase(sl()))
    ..registerFactory(() => DeleteMessageUseCase(sl()))
    ..registerFactory(() => WatchConversationsUseCase(sl()));
}
