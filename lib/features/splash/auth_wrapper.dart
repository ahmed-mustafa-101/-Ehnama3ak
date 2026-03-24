import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/presentation/controllers/auth_cubit.dart';
import '../auth/presentation/controllers/auth_state.dart';
import '../../core/widgets/main_layout.dart';
import 'splash_screen.dart';

/// Wrapper that checks auth state and navigates accordingly
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check auth status on app start
    context.read<AuthCubit>().checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Show loading while checking auth
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in -> go to main app
        if (state is AuthSuccess) {
          return const MainLayout();
        }

        // User is not logged in -> show splash/welcome
        return const SplashScreen();
      },
    );
  }
}
