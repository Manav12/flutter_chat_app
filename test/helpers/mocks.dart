// This file has all fake/mock version of repository, use case and data
// source classes, shared by test files, so nothing real (Firestore,
// Hive, network) ever run during test.
import 'package:mocktail/mocktail.dart';

import 'package:flutter_chat_app/core/network/network_info.dart';
import 'package:flutter_chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/edit_message_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/send_image_message_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:flutter_chat_app/features/users/data/datasources/user_local_data_source.dart';
import 'package:flutter_chat_app/features/users/data/datasources/user_remote_data_source.dart';
import 'package:flutter_chat_app/features/users/domain/entities/user_entity.dart';
import 'package:flutter_chat_app/features/users/domain/repositories/user_repository.dart';
import 'package:flutter_chat_app/features/users/domain/usecases/update_profile_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockUserRemoteDataSource extends Mock implements UserRemoteDataSource {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockUpdatePasswordUseCase extends Mock implements UpdatePasswordUseCase {}

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

class MockSendImageMessageUseCase extends Mock
    implements SendImageMessageUseCase {}

class MockWatchMessagesUseCase extends Mock implements WatchMessagesUseCase {}

class MockEditMessageUseCase extends Mock implements EditMessageUseCase {}

class MockDeleteMessageUseCase extends Mock implements DeleteMessageUseCase {}

// mocktail needs a stand-in value for any custom type used with any()
// as an argument matcher — these Fakes are only ever used for that,
// never actually run.
class FakeUserEntity extends Fake implements UserEntity {}

class FakeLoginParams extends Fake implements LoginParams {}

class FakeRegisterParams extends Fake implements RegisterParams {}

class FakeUpdatePasswordParams extends Fake implements UpdatePasswordParams {}

class FakeSendMessageParams extends Fake implements SendMessageParams {}

class FakeSendImageMessageParams extends Fake
    implements SendImageMessageParams {}

class FakeWatchMessagesParams extends Fake implements WatchMessagesParams {}

class FakeMessageEntity extends Fake implements MessageEntity {}
