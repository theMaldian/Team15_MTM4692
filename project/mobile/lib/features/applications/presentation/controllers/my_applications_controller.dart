import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/features/applications/data/applications_repository.dart';
import 'package:ytu_assistant/features/applications/data/models/application_model.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';

/// The signed-in student's applications (`GET /applications/my`).
class MyApplicationsController extends AsyncNotifier<List<ApplicationModel>> {
  @override
  Future<List<ApplicationModel>> build() {
    // Long-lived provider: re-run when the signed-in user changes so a new
    // student never sees the previous student's applications.
    ref.watch(
      authControllerProvider.select(
        (AsyncValue<UserModel?> auth) => auth.valueOrNull?.userId,
      ),
    );
    return ref.read(applicationsRepositoryProvider).fetchMine();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<ApplicationModel>>();
    state = await AsyncValue.guard<List<ApplicationModel>>(
      () => ref.read(applicationsRepositoryProvider).fetchMine(),
    );
  }
}

final myApplicationsControllerProvider =
    AsyncNotifierProvider<MyApplicationsController, List<ApplicationModel>>(
  MyApplicationsController.new,
);
