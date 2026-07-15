// This is start point of app. It set up all connection, then open
// first screen.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/network/network_info.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_banner.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  final AuthBloc authBloc = sl<AuthBloc>();
  final GoRouter router = buildRouter(authBloc);

  runApp(ChatApp(authBloc: authBloc, router: router));
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key, required this.authBloc, required this.router});

  final AuthBloc authBloc;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => ConnectivityBanner(
          networkInfo: sl<NetworkInfo>(),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
