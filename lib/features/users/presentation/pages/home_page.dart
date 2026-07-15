import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/double_back_to_exit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// This is main page, user come here after login. Right now it just
// showing welcome message as placeholder — later this page will show
// list of all other user, so this user can open chat with them.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthBloc>().state.user?.name ?? '';
    return DoubleBackToExit(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),
        body: Center(
          child: Text('Welcome, $userName!', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
