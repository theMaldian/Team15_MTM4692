import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/router/main_shell.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/domain/user_role.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/change_password_screen.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/login_screen.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/register_screen.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/splash_screen.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:ytu_assistant/features/jobs/presentation/screens/applicants_screen.dart';
import 'package:ytu_assistant/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:ytu_assistant/features/jobs/presentation/screens/job_form_screen.dart';
import 'package:ytu_assistant/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:ytu_assistant/features/jobs/presentation/screens/my_jobs_screen.dart';
import 'package:ytu_assistant/features/applications/presentation/screens/applicant_detail_screen.dart';
import 'package:ytu_assistant/features/applications/presentation/screens/my_applications_screen.dart';
import 'package:ytu_assistant/features/jobs/data/models/applicant_model.dart';
import 'package:ytu_assistant/features/profile/data/models/education_model.dart';
import 'package:ytu_assistant/features/profile/data/models/experience_model.dart';
import 'package:ytu_assistant/features/profile/presentation/screens/education_form_screen.dart';
import 'package:ytu_assistant/features/profile/presentation/screens/experience_form_screen.dart';
import 'package:ytu_assistant/features/profile/presentation/screens/manage_languages_screen.dart';
import 'package:ytu_assistant/features/profile/presentation/screens/manage_skills_screen.dart';
import 'package:ytu_assistant/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:ytu_assistant/features/profile/presentation/screens/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String home = '/home';

  static const String jobs = '/jobs';
  static const String newJob = '/jobs/new';
  static const String myJobs = '/my-jobs';
  static const String myJobsClosed = '/my-jobs/closed';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profileSkills = '/profile/skills';
  static const String profileLanguages = '/profile/languages';
  static const String profileExperience = '/profile/experience';
  static const String profileEducation = '/profile/education';

  static const String myApplications = '/my-applications';
}

/// Routes reachable while signed out.
const Set<String> _publicRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.verifyEmail,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
};

/// Route PATTERNS only professors may open. Matched against `state.fullPath`.
const Set<String> _professorOnlyPatterns = <String>{
  '/my-jobs',
  '/my-jobs/closed',
  '/jobs/new',
  '/jobs/:id/edit',
  '/jobs/:id/applicants',
  '/jobs/:id/applicants/:userId',
};

/// Route PATTERNS only students may open. Matched against `state.fullPath`.
const Set<String> _studentOnlyPatterns = <String>{
  '/my-applications',
};

String _landingFor(UserModel user) =>
    user.role == UserRole.professor ? AppRoutes.myJobs : AppRoutes.jobs;

/// Bridges Riverpod auth state → GoRouter so redirects re-run on changes.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _sub = _ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<UserModel?>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final _RouterRefreshNotifier refresh = _RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<UserModel?> auth = ref.read(authControllerProvider);
      final String location = state.matchedLocation;

      // Still bootstrapping → splash.
      if (auth.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // Treat bootstrap errors as "no session".
      final UserModel? user = auth.valueOrNull;

      if (user == null) {
        if (location == AppRoutes.splash) {
          return AppRoutes.login;
        }
        return _publicRoutes.contains(location) ? null : AppRoutes.login;
      }

      // Signed in but unverified → force verification.
      final bool unverified = user.isVerified == false;
      if (unverified && location != AppRoutes.verifyEmail) {
        return Uri(
          path: AppRoutes.verifyEmail,
          queryParameters: <String, String>{'email': user.email},
        ).toString();
      }

      // Signed in on a guest-only entry route → role landing.
      if (location == AppRoutes.splash ||
          location == AppRoutes.login ||
          location == AppRoutes.register) {
        return _landingFor(user);
      }

      // Role guard: students cannot open professor-only routes.
      if (user.role == UserRole.student &&
          _professorOnlyPatterns.contains(state.fullPath)) {
        return Uri(
          path: AppRoutes.jobs,
          queryParameters: <String, String>{'denied': 'students'},
        ).toString();
      }

      // Role guard: professors cannot open student-only routes.
      if (user.role == UserRole.professor &&
          _studentOnlyPatterns.contains(state.fullPath)) {
        return _landingFor(user);
      }

      return null;
    },
    routes: <RouteBase>[
      // ---- Auth (full-screen, outside the shell) ----
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: 'verify-email',
        builder: (BuildContext context, GoRouterState state) =>
            VerifyEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'reset-password',
        builder: (BuildContext context, GoRouterState state) =>
            ResetPasswordScreen(
          email: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'change-password',
        builder: (_, __) => const ChangePasswordScreen(),
      ),

      // ---- /home → role-aware landing ----
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        redirect: (BuildContext context, GoRouterState state) {
          final UserModel? user = ref.read(authControllerProvider).valueOrNull;
          return user == null ? AppRoutes.login : _landingFor(user);
        },
      ),

      // ---- Full-screen job routes (over the shell) ----
      // `/jobs/new` MUST be declared before `/jobs/:id`.
      GoRoute(
        path: AppRoutes.newJob,
        name: 'job-new',
        builder: (_, __) => const JobFormScreen(),
      ),
      GoRoute(
        path: '/jobs/:id/edit',
        name: 'job-edit',
        builder: (BuildContext context, GoRouterState state) => JobFormScreen(
          jobId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/jobs/:id/applicants',
        name: 'job-applicants',
        builder: (BuildContext context, GoRouterState state) => ApplicantsScreen(
          jobId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/jobs/:id/applicants/:userId',
        name: 'applicant-detail',
        builder: (BuildContext context, GoRouterState state) =>
            ApplicantDetailScreen(
          jobId: int.parse(state.pathParameters['id']!),
          userId: int.parse(state.pathParameters['userId']!),
          applicant:
              state.extra is ApplicantModel ? state.extra as ApplicantModel : null,
        ),
      ),
      GoRoute(
        path: '/jobs/:id',
        name: 'job-detail',
        builder: (BuildContext context, GoRouterState state) => JobDetailScreen(
          jobId: int.parse(state.pathParameters['id']!),
        ),
      ),

      // ---- Profile sub-screens (full-screen, over the shell) ----
      GoRoute(
        path: AppRoutes.profileEdit,
        name: 'profile-edit',
        builder: (_, __) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSkills,
        name: 'profile-skills',
        builder: (_, __) => const ManageSkillsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileLanguages,
        name: 'profile-languages',
        builder: (_, __) => const ManageLanguagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileExperience,
        name: 'profile-experience',
        builder: (BuildContext context, GoRouterState state) =>
            ExperienceFormScreen(
          experience: state.extra is ExperienceModel
              ? state.extra as ExperienceModel
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.profileEducation,
        name: 'profile-education',
        builder: (BuildContext context, GoRouterState state) =>
            EducationFormScreen(
          education: state.extra is EducationModel
              ? state.extra as EducationModel
              : null,
        ),
      ),

      // ---- Authenticated shell with bottom navigation ----
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            MainShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.jobs,
            name: 'jobs',
            builder: (_, __) => const JobListScreen(),
          ),
          GoRoute(
            path: AppRoutes.myJobs,
            name: 'my-jobs',
            builder: (_, __) => const MyJobsScreen(),
          ),
          GoRoute(
            path: AppRoutes.myJobsClosed,
            name: 'my-jobs-closed',
            builder: (_, __) => const ClosedJobsScreen(),
          ),
          GoRoute(
            path: AppRoutes.myApplications,
            name: 'my-applications',
            builder: (_, __) => const MyApplicationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
