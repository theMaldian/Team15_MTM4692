/// All backend endpoint paths as constants.
///
/// Mirrors `project/BACKEND_API.md`. The backend mounts routers WITHOUT a global
/// `/api` prefix: `/auth`, `/jobs`, `/profile`, `/applications`, and catalog
/// routes at root (`/skills`, `/languages`).
///
/// Methods with a path parameter are exposed as helper functions.
class ApiEndpoints {
  ApiEndpoints._();

  // ---- Auth ----
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // ---- Catalog (mounted at root) ----
  static const String skills = '/skills';
  static const String languages = '/languages';

  // ---- Jobs ----
  static const String jobs = '/jobs';
  static const String activeJobs = '/jobs/active';
  static const String myJobs = '/jobs/my';

  static String job(Object jobId) => '/jobs/$jobId';
  static String jobApplicants(Object jobId) => '/jobs/$jobId/applicants';
  static String closeJob(Object jobId) => '/jobs/$jobId/close';
  static String applyToJob(Object jobId) => '/jobs/$jobId/apply';

  // ---- Applications ----
  static const String myApplications = '/applications/my';

  static String application(Object applicationId) =>
      '/applications/$applicationId';
  static String applicationStatus(Object applicationId) =>
      '/applications/$applicationId/status';

  // ---- Profile ----
  static const String profile = '/profile';
  static const String profileSkills = '/profile/skills';
  static const String profileLanguages = '/profile/languages';
  static const String profileExperiences = '/profile/experiences';
  static const String profileEducations = '/profile/educations';

  static String profileSkill(Object skillId) => '/profile/skills/$skillId';
  static String profileLanguage(Object languageId) =>
      '/profile/languages/$languageId';
  static String profileExperience(Object experienceId) =>
      '/profile/experiences/$experienceId';
  static String profileEducation(Object educationId) =>
      '/profile/educations/$educationId';
}
