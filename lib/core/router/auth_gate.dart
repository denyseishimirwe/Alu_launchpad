import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/founder/screens/founder_shell.dart';
import '../../features/student/screens/student_shell.dart';
import '../../shared/widgets/loading_screen.dart';

enum AuthPage { login, signup }

/// Handles login/signup locally so text fields are not reset by router redirects.
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  AuthPage _page = AuthPage.login;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _page.index,
      children: [
        LoginScreen(
          onSignupTap: () => setState(() => _page = AuthPage.signup),
        ),
        SignupScreen(
          onSignInTap: () => setState(() => _page = AuthPage.login),
        ),
      ],
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final profile = ref.watch(currentUserProfileProvider);

    if (auth.isLoading) {
      return const LoadingScreen();
    }

    if (auth.value == null) {
      return const AuthFlow();
    }

    if (profile.isLoading) {
      return const LoadingScreen();
    }

    final userProfile = profile.value;
    if (userProfile == null || !userProfile.hasRole) {
      return const RoleSelectionScreen();
    }

    if (userProfile.isFounder) {
      return const FounderShell();
    }

    return const StudentShell();
  }
}
