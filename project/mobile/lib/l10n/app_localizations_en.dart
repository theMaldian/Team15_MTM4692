// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'YTU Assistant';

  @override
  String get appTagline => 'YTU Recruitment System';

  @override
  String get languageTurkish => 'TR';

  @override
  String get languageEnglish => 'EN';

  @override
  String get toggleLanguage => 'Change language';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get emailHint => 'name@std.yildiz.edu.tr';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dividerOr => 'or';

  @override
  String get actionCreateAccount => 'Create account';

  @override
  String get noAccountQuestion => 'Don\'t have an account? ';

  @override
  String get actionSignUp => 'Sign up';

  @override
  String get snackInvalidCredentials => 'Invalid email or password';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle =>
      'Use your YTU email. Your role is decided by the email domain you sign up with.';

  @override
  String get fieldFirstName => 'First name';

  @override
  String get fieldLastName => 'Last name';

  @override
  String get fieldFaculty => 'Faculty';

  @override
  String get fieldDepartment => 'Department';

  @override
  String get fieldPasswordConfirm => 'Confirm password';

  @override
  String get actionRegister => 'Sign up';

  @override
  String get chooseFaculty => 'Choose your faculty';

  @override
  String get chooseDepartment => 'Choose your department';

  @override
  String get selectFacultyFirst => 'Select a faculty first';

  @override
  String get registerNote =>
      'Note: faculty and department are saved to your profile after you sign in.';

  @override
  String get haveAccountQuestion => 'Already have an account? ';

  @override
  String get snackAccountCreated =>
      'Account created. Check your email for the verification code.';

  @override
  String get snackEmailExists => 'An account with this email already exists';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleProfessor => 'Academic';

  @override
  String get verifyTitle => 'Verify your email';

  @override
  String verifySubtitle(String email) {
    return 'We sent a 6-digit code to $email. Enter it below to activate your account.';
  }

  @override
  String get fieldVerificationCode => 'Verification code';

  @override
  String get hintSixDigitCode => '6-digit code';

  @override
  String get actionVerify => 'Verify email';

  @override
  String get noCodeQuestion => 'Didn\'t receive a code? ';

  @override
  String get actionResend => 'Resend';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get codeExpiresNote => 'The code expires after 10 minutes.';

  @override
  String get snackEmailVerified => 'Email verified. You can sign in now.';

  @override
  String get snackCodeSent => 'Verification code sent.';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotSubtitle =>
      'Enter your YTU email and we\'ll send you a code to reset your password.';

  @override
  String get actionSendCode => 'Send code';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String checkEmailSubtitle(String email) {
    return 'If an account exists for $email, we\'ve sent a 6-digit reset code. It expires in 10 minutes.';
  }

  @override
  String get actionEnterResetCode => 'Enter reset code';

  @override
  String get actionBackToSignIn => 'Back to sign in';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetSubtitle =>
      'Enter the 6-digit code we emailed you, plus a new password.';

  @override
  String get fieldResetCode => 'Reset code';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get fieldConfirmNewPassword => 'Confirm new password';

  @override
  String get actionReset => 'Reset password';

  @override
  String get snackPasswordReset => 'Password reset. You can sign in now.';

  @override
  String get pwHintLength => 'At least 8 characters';

  @override
  String get pwHintLetter => 'Contains a letter';

  @override
  String get pwHintNumber => 'Contains a number';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get valEmailRequired => 'Email is required';

  @override
  String get valEmailInvalid => 'Enter a valid email address';

  @override
  String valEmailDomain(String student, String professor) {
    return 'Use your YTU email ($student or $professor)';
  }

  @override
  String get valPasswordRequired => 'Password is required';

  @override
  String get valPasswordMin => 'Password must be at least 8 characters';

  @override
  String get valPasswordLetter => 'Password must contain at least one letter';

  @override
  String get valPasswordNumber => 'Password must contain at least one number';

  @override
  String get valRequired => 'This field is required';

  @override
  String get valMinChars => 'Must be at least 2 characters';

  @override
  String get valMaxChars => 'Must be at most 50 characters';

  @override
  String get valCodeRequired => 'Code is required';

  @override
  String get valCodeSixDigits => 'Enter the 6-digit code';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get jobsTitle => 'Opportunities';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get jobSeeDetails => 'See details';

  @override
  String get emptyNoPostingsTitle => 'No open postings';

  @override
  String get emptyNoPostingsSubtitle =>
      'Check back later for new opportunities.';

  @override
  String get emptyNoMatchTitle => 'No matching postings';

  @override
  String get emptyNoMatchSubtitle => 'Try clearing or changing your filters.';

  @override
  String get actionClearFilters => 'Clear filters';

  @override
  String get errorLoadTitle => 'Could not load postings';

  @override
  String get errorLoadSubtitle =>
      'Something went wrong while loading opportunities.';

  @override
  String get actionRetry => 'Retry';

  @override
  String get studentOnlyTitle => 'Student-only feed';

  @override
  String get studentOnlySubtitle =>
      'Browsing active postings is available to students. Use \"My Postings\" to manage your jobs.';

  @override
  String get deniedForStudents => 'Not available for students';

  @override
  String get statusActive => 'Active';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusExpired => 'Expired';

  @override
  String get deadlineExpired => 'Expired';

  @override
  String get deadlineDueToday => 'Due today';

  @override
  String deadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String deadlineDue(String date) {
    return 'Due $date';
  }

  @override
  String applicantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applicants',
      one: '1 applicant',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending',
    );
    return '$_temp0';
  }

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorConnection =>
      'Connection error. Check your internet and try again.';

  @override
  String get errorForbidden => 'You don\'t have permission for this action';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get navOpportunities => 'Opportunities';

  @override
  String get navApplications => 'My Applications';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMyPostings => 'My Postings';

  @override
  String get navExplore => 'Explore';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionViewJob => 'View posting';

  @override
  String get appStatusPending => 'Pending';

  @override
  String get appStatusApproved => 'Approved';

  @override
  String get appStatusRejected => 'Rejected';

  @override
  String get myApplicationsTitle => 'My Applications';

  @override
  String get applicationsEmptyTitle => 'No applications yet';

  @override
  String get applicationsEmptySubtitle => 'Jobs you apply to will appear here.';

  @override
  String get applicationsErrorTitle => 'Could not load applications';

  @override
  String appliedOn(String date) {
    return 'Applied on $date';
  }

  @override
  String get withdrawAction => 'Withdraw application';

  @override
  String get withdrawConfirmTitle => 'Withdraw application?';

  @override
  String withdrawConfirmBody(String position) {
    return 'Your application to \"$position\" will be withdrawn.';
  }

  @override
  String get withdrawSuccess => 'Application withdrawn';

  @override
  String get applicantDetailTitle => 'Applicant';

  @override
  String get updateStatusAction => 'Update status';

  @override
  String get statusUpdateSheetTitle => 'Update status';

  @override
  String get statusUpdatedSuccess => 'Status updated';

  @override
  String get statusTimelineApplied => 'Applied';

  @override
  String get statusTimelineReview => 'In review';

  @override
  String get statusTimelineResult => 'Result';

  @override
  String get labelClassYear => 'Class year';

  @override
  String get labelGpa => 'GPA';

  @override
  String get labelAppliedDate => 'Applied date';

  @override
  String get labelUniversity => 'University';

  @override
  String get labelDegreeLevel => 'Degree level';

  @override
  String get labelPhone => 'Phone';

  @override
  String get labelExpectedGraduation => 'Expected graduation';

  @override
  String get labelAcademicTitle => 'Academic title';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfileAction => 'Edit profile';

  @override
  String get logoutAction => 'Log out';

  @override
  String get changePasswordAction => 'Change password';

  @override
  String get sectionSkills => 'Skills';

  @override
  String get sectionLanguages => 'Languages';

  @override
  String get sectionExperience => 'Experience';

  @override
  String get sectionEducation => 'Education';

  @override
  String get emptySectionGeneric => 'Nothing added yet';

  @override
  String get profileErrorTitle => 'Could not load profile';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get profileSavedSuccess => 'Profile updated';

  @override
  String get manageSkillsTitle => 'Skills';

  @override
  String get searchSkillsHint => 'Search skills';

  @override
  String get yourSkills => 'Your skills';

  @override
  String get noSkillsYet => 'No skills added yet';

  @override
  String get skillsCatalogEmpty => 'No matching skills';

  @override
  String get manageLanguagesTitle => 'Languages';

  @override
  String get searchLanguagesHint => 'Search languages';

  @override
  String get yourLanguages => 'Your languages';

  @override
  String get noLanguagesYet => 'No languages added yet';

  @override
  String get selectLevel => 'Select level';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelNative => 'Native';

  @override
  String get experienceAddTitle => 'Add experience';

  @override
  String get experienceEditTitle => 'Edit experience';

  @override
  String get experienceEmpty => 'No experience added yet';

  @override
  String get deleteExperienceConfirm => 'Delete this experience?';

  @override
  String get fieldCompany => 'Company';

  @override
  String get fieldPosition => 'Position';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldStartDate => 'Start date';

  @override
  String get fieldEndDate => 'End date';

  @override
  String get stillHere => 'Currently here';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get educationAddTitle => 'Add education';

  @override
  String get educationEditTitle => 'Edit education';

  @override
  String get educationEmpty => 'No education added yet';

  @override
  String get deleteEducationConfirm => 'Delete this education?';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldUniversity => 'University';

  @override
  String get fieldDegreeLevel => 'Degree level';

  @override
  String get fieldClassYear => 'Class year';

  @override
  String get fieldGpa => 'GPA';

  @override
  String get fieldExpectedGraduation => 'Expected graduation date';

  @override
  String get fieldAcademicTitle => 'Academic title';

  @override
  String get pickDate => 'Pick date';

  @override
  String get notProvided => 'Not provided';

  @override
  String get valGpaRange => 'Enter a value between 0 and 4';

  @override
  String get valClassYear => 'Enter a valid class year';

  @override
  String get catCourseAssistant => 'Course Assistant';

  @override
  String get catLabAssistant => 'Lab Assistant';

  @override
  String get catResearchAssistant => 'Research Assistant';

  @override
  String get catOther => 'Other';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortDeadlineSoonest => 'Deadline soonest';

  @override
  String get sortGpaHighToLow => 'GPA (high to low)';

  @override
  String get filterSheetTitle => 'Filter postings';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterSortBy => 'Sort by';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterApply => 'Apply';

  @override
  String get filterDeptHint => 'e.g. Computer Engineering';

  @override
  String filterDeptChip(String dept) {
    return 'Dept: $dept';
  }

  @override
  String get detailAboutPosition => 'About this position';

  @override
  String get detailPostedBy => 'Posted by';

  @override
  String get detailTimeline => 'Timeline';

  @override
  String get detailPostedLabel => 'Posted';

  @override
  String get applicationDeadlineLabel => 'Application deadline';

  @override
  String get applicantsLabel => 'Applicants';

  @override
  String get copyLinkTooltip => 'Copy link';

  @override
  String get linkCopiedMsg => 'Link copied to clipboard';

  @override
  String get applicationSubmittedMsg => 'Application submitted';

  @override
  String get alreadyAppliedMsg => 'You have already applied to this job';

  @override
  String get postingNoLongerAvailable => 'This posting is no longer available';

  @override
  String get viewApplicantsAction => 'View Applicants';

  @override
  String get couldNotLoadPosting => 'Could not load posting';

  @override
  String get thisPostingNotFound => 'This posting could not be found.';

  @override
  String get actionGoBack => 'Go back';

  @override
  String get applyButtonIdle => 'Apply';

  @override
  String get applyButtonApplied => 'Applied';

  @override
  String get applyButtonExpired => 'Deadline passed';

  @override
  String get applicantsScreenTitle => 'Applicants';

  @override
  String get couldNotLoadApplicants => 'Could not load applicants';

  @override
  String get noAccessToPosting => 'You don\'t have access to this posting';

  @override
  String get postingNotFound => 'Posting not found';

  @override
  String get noApplicantsYet => 'No applicants yet';

  @override
  String get applicantsWillAppear =>
      'Applications will appear here as students apply.';

  @override
  String get jobFormNewTitle => 'New Posting';

  @override
  String get jobFormEditTitle => 'Edit Posting';

  @override
  String get positionHint => 'e.g. Teaching Assistant for CSE2024';

  @override
  String get jobPositionRequired => 'Position is required';

  @override
  String jobPositionTooLong(int max) {
    return 'Keep it under $max characters';
  }

  @override
  String get chooseCategoryPrompt => 'Choose a category';

  @override
  String get deptHint => 'e.g. Computer Engineering';

  @override
  String get deptRequired => 'Department is required';

  @override
  String get descriptionHint => 'Responsibilities, requirements, hours…';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String descriptionTooLong(int max) {
    return 'Keep it under $max characters';
  }

  @override
  String get selectDate => 'Select a date';

  @override
  String get deadlineRequired => 'Deadline is required';

  @override
  String get publishAction => 'Publish';

  @override
  String get saveChangesAction => 'Save changes';

  @override
  String get changesSavedMsg => 'Changes saved';

  @override
  String get postingPublishedMsg => 'Posting published';

  @override
  String get navActivePostings => 'Active Postings';

  @override
  String get navInactivePostings => 'Inactive Postings';

  @override
  String get newPostingTooltip => 'New posting';

  @override
  String get actionCreatePosting => 'Create posting';

  @override
  String get myJobsErrorTitle => 'Could not load your postings';

  @override
  String get myJobsEmptyActiveTitle => 'No active postings';

  @override
  String get myJobsEmptyActiveSubtitle => 'Create your first job posting.';

  @override
  String get myJobsEmptyInactiveTitle => 'No inactive postings';

  @override
  String get myJobsEmptyInactiveSubtitle =>
      'Closed or expired postings appear here.';

  @override
  String get closePostingTitle => 'Close posting?';

  @override
  String closePostingBody(String position) {
    return 'Students can no longer apply to \"$position\". Existing applications are kept.';
  }

  @override
  String get actionClosePosting => 'Close posting';

  @override
  String get postingClosedSuccess => 'Posting closed';
}
