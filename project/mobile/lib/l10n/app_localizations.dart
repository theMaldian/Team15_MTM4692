import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'YTÜ Asistan'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In tr, this message translates to:
  /// **'YTÜ İşe Alım Sistemi'**
  String get appTagline;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'TR'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'EN'**
  String get languageEnglish;

  /// No description provided for @toggleLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dili değiştir'**
  String get toggleLanguage;

  /// No description provided for @fieldEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get fieldPassword;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'ad@std.yildiz.edu.tr'**
  String get emailHint;

  /// No description provided for @loginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar hoş geldin'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için giriş yap'**
  String get loginSubtitle;

  /// No description provided for @actionSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get actionSignIn;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPassword;

  /// No description provided for @dividerOr.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get dividerOr;

  /// No description provided for @actionCreateAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get actionCreateAccount;

  /// No description provided for @noAccountQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? '**
  String get noAccountQuestion;

  /// No description provided for @actionSignUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get actionSignUp;

  /// No description provided for @snackInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı'**
  String get snackInvalidCredentials;

  /// No description provided for @registerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'YTÜ e-postanı kullan. Rolün, kayıt olduğun e-posta alan adına göre belirlenir.'**
  String get registerSubtitle;

  /// No description provided for @fieldFirstName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get fieldLastName;

  /// No description provided for @fieldFaculty.
  ///
  /// In tr, this message translates to:
  /// **'Fakülte'**
  String get fieldFaculty;

  /// No description provided for @fieldDepartment.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm'**
  String get fieldDepartment;

  /// No description provided for @fieldPasswordConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Şifre tekrar'**
  String get fieldPasswordConfirm;

  /// No description provided for @actionRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get actionRegister;

  /// No description provided for @chooseFaculty.
  ///
  /// In tr, this message translates to:
  /// **'Fakülteni seç'**
  String get chooseFaculty;

  /// No description provided for @chooseDepartment.
  ///
  /// In tr, this message translates to:
  /// **'Bölümünü seç'**
  String get chooseDepartment;

  /// No description provided for @selectFacultyFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce fakülteyi seç'**
  String get selectFacultyFirst;

  /// No description provided for @registerNote.
  ///
  /// In tr, this message translates to:
  /// **'Not: fakülte ve bölüm, giriş yaptıktan sonra profiline kaydedilir.'**
  String get registerNote;

  /// No description provided for @haveAccountQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? '**
  String get haveAccountQuestion;

  /// No description provided for @snackAccountCreated.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluşturuldu. Doğrulama kodu için e-postanı kontrol et.'**
  String get snackAccountCreated;

  /// No description provided for @snackEmailExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile bir hesap zaten var'**
  String get snackEmailExists;

  /// No description provided for @roleStudent.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenci'**
  String get roleStudent;

  /// No description provided for @roleProfessor.
  ///
  /// In tr, this message translates to:
  /// **'Akademisyen'**
  String get roleProfessor;

  /// No description provided for @verifyTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı doğrula'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine 6 haneli bir kod gönderdik. Hesabını etkinleştirmek için aşağıya gir.'**
  String verifySubtitle(String email);

  /// No description provided for @fieldVerificationCode.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu'**
  String get fieldVerificationCode;

  /// No description provided for @hintSixDigitCode.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kod'**
  String get hintSixDigitCode;

  /// No description provided for @actionVerify.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı doğrula'**
  String get actionVerify;

  /// No description provided for @noCodeQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Kod gelmedi mi? '**
  String get noCodeQuestion;

  /// No description provided for @actionResend.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar gönder'**
  String get actionResend;

  /// No description provided for @resendIn.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} sn sonra tekrar'**
  String resendIn(int seconds);

  /// No description provided for @codeExpiresNote.
  ///
  /// In tr, this message translates to:
  /// **'Kod 10 dakika sonra geçersiz olur.'**
  String get codeExpiresNote;

  /// No description provided for @snackEmailVerified.
  ///
  /// In tr, this message translates to:
  /// **'E-posta doğrulandı. Artık giriş yapabilirsin.'**
  String get snackEmailVerified;

  /// No description provided for @snackCodeSent.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama kodu gönderildi.'**
  String get snackCodeSent;

  /// No description provided for @forgotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni mi unuttun'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'YTÜ e-postanı gir, şifreni sıfırlaman için sana bir kod gönderelim.'**
  String get forgotSubtitle;

  /// No description provided for @actionSendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kod gönder'**
  String get actionSendCode;

  /// No description provided for @checkEmailTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı kontrol et'**
  String get checkEmailTitle;

  /// No description provided for @checkEmailSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{email} için bir hesap varsa, 6 haneli bir sıfırlama kodu gönderdik. Kod 10 dakika içinde geçersiz olur.'**
  String checkEmailSubtitle(String email);

  /// No description provided for @actionEnterResetCode.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama kodunu gir'**
  String get actionEnterResetCode;

  /// No description provided for @actionBackToSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Girişe dön'**
  String get actionBackToSignIn;

  /// No description provided for @resetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi sıfırla'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postana gönderdiğimiz 6 haneli kodu ve yeni bir şifre gir.'**
  String get resetSubtitle;

  /// No description provided for @fieldResetCode.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama kodu'**
  String get fieldResetCode;

  /// No description provided for @fieldNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get fieldNewPassword;

  /// No description provided for @fieldConfirmNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre tekrar'**
  String get fieldConfirmNewPassword;

  /// No description provided for @actionReset.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi sıfırla'**
  String get actionReset;

  /// No description provided for @snackPasswordReset.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlandı. Artık giriş yapabilirsin.'**
  String get snackPasswordReset;

  /// No description provided for @pwHintLength.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter'**
  String get pwHintLength;

  /// No description provided for @pwHintLetter.
  ///
  /// In tr, this message translates to:
  /// **'Bir harf içerir'**
  String get pwHintLetter;

  /// No description provided for @pwHintNumber.
  ///
  /// In tr, this message translates to:
  /// **'Bir rakam içerir'**
  String get pwHintNumber;

  /// No description provided for @showPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get hidePassword;

  /// No description provided for @valEmailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gerekli'**
  String get valEmailRequired;

  /// No description provided for @valEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi gir'**
  String get valEmailInvalid;

  /// No description provided for @valEmailDomain.
  ///
  /// In tr, this message translates to:
  /// **'YTÜ e-postanı kullan ({student} veya {professor})'**
  String valEmailDomain(String student, String professor);

  /// No description provided for @valPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get valPasswordRequired;

  /// No description provided for @valPasswordMin.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter olmalı'**
  String get valPasswordMin;

  /// No description provided for @valPasswordLetter.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az bir harf içermeli'**
  String get valPasswordLetter;

  /// No description provided for @valPasswordNumber.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az bir rakam içermeli'**
  String get valPasswordNumber;

  /// No description provided for @valRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan zorunlu'**
  String get valRequired;

  /// No description provided for @valMinChars.
  ///
  /// In tr, this message translates to:
  /// **'En az 2 karakter olmalı'**
  String get valMinChars;

  /// No description provided for @valMaxChars.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 50 karakter olmalı'**
  String get valMaxChars;

  /// No description provided for @valCodeRequired.
  ///
  /// In tr, this message translates to:
  /// **'Kod gerekli'**
  String get valCodeRequired;

  /// No description provided for @valCodeSixDigits.
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kodu gir'**
  String get valCodeSixDigits;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordsDoNotMatch;

  /// No description provided for @jobsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fırsatlar'**
  String get jobsTitle;

  /// No description provided for @filterTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filterTooltip;

  /// No description provided for @jobSeeDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detayları gör'**
  String get jobSeeDetails;

  /// No description provided for @emptyNoPostingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Açık ilan yok'**
  String get emptyNoPostingsTitle;

  /// No description provided for @emptyNoPostingsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni fırsatlar için daha sonra tekrar bak.'**
  String get emptyNoPostingsSubtitle;

  /// No description provided for @emptyNoMatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen ilan yok'**
  String get emptyNoMatchTitle;

  /// No description provided for @emptyNoMatchSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Filtrelerini temizlemeyi veya değiştirmeyi dene.'**
  String get emptyNoMatchSubtitle;

  /// No description provided for @actionClearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get actionClearFilters;

  /// No description provided for @errorLoadTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlanlar yüklenemedi'**
  String get errorLoadTitle;

  /// No description provided for @errorLoadSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Fırsatlar yüklenirken bir şeyler ters gitti.'**
  String get errorLoadSubtitle;

  /// No description provided for @actionRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get actionRetry;

  /// No description provided for @studentOnlyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öğrencilere özel akış'**
  String get studentOnlyTitle;

  /// No description provided for @studentOnlySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif ilanlara göz atmak öğrencilere açıktır. İlanlarını yönetmek için \"İlanlarım\" bölümünü kullan.'**
  String get studentOnlySubtitle;

  /// No description provided for @deniedForStudents.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenciler için kullanılamaz'**
  String get deniedForStudents;

  /// No description provided for @statusActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get statusActive;

  /// No description provided for @statusClosed.
  ///
  /// In tr, this message translates to:
  /// **'Kapandı'**
  String get statusClosed;

  /// No description provided for @statusExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi doldu'**
  String get statusExpired;

  /// No description provided for @deadlineExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi doldu'**
  String get deadlineExpired;

  /// No description provided for @deadlineDueToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün son'**
  String get deadlineDueToday;

  /// No description provided for @deadlineDaysLeft.
  ///
  /// In tr, this message translates to:
  /// **'{days, plural, other{{days} gün kaldı}}'**
  String deadlineDaysLeft(int days);

  /// No description provided for @deadlineDue.
  ///
  /// In tr, this message translates to:
  /// **'Son: {date}'**
  String deadlineDue(String date);

  /// No description provided for @applicantsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} başvuru}}'**
  String applicantsCount(int count);

  /// No description provided for @pendingCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} bekliyor}}'**
  String pendingCount(int count);

  /// No description provided for @errorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti. Lütfen tekrar dene.'**
  String get errorGeneric;

  /// No description provided for @errorConnection.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı hatası. İnternetini kontrol edip tekrar dene.'**
  String get errorConnection;

  /// No description provided for @errorForbidden.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkin yok'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bulunamadı'**
  String get errorNotFound;

  /// No description provided for @navOpportunities.
  ///
  /// In tr, this message translates to:
  /// **'Fırsatlar'**
  String get navOpportunities;

  /// No description provided for @navApplications.
  ///
  /// In tr, this message translates to:
  /// **'Başvurularım'**
  String get navApplications;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navMyPostings.
  ///
  /// In tr, this message translates to:
  /// **'İlanlarım'**
  String get navMyPostings;

  /// No description provided for @navExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get navExplore;

  /// No description provided for @actionAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get actionConfirm;

  /// No description provided for @actionViewJob.
  ///
  /// In tr, this message translates to:
  /// **'İlanı gör'**
  String get actionViewJob;

  /// No description provided for @appStatusPending.
  ///
  /// In tr, this message translates to:
  /// **'Beklemede'**
  String get appStatusPending;

  /// No description provided for @appStatusApproved.
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get appStatusApproved;

  /// No description provided for @appStatusRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get appStatusRejected;

  /// No description provided for @myApplicationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvurularım'**
  String get myApplicationsTitle;

  /// No description provided for @applicationsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz başvurun yok'**
  String get applicationsEmptyTitle;

  /// No description provided for @applicationsEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvurduğun ilanlar burada görünecek.'**
  String get applicationsEmptySubtitle;

  /// No description provided for @applicationsErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvurular yüklenemedi'**
  String get applicationsErrorTitle;

  /// No description provided for @appliedOn.
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihinde başvuruldu'**
  String appliedOn(String date);

  /// No description provided for @withdrawAction.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruyu geri çek'**
  String get withdrawAction;

  /// No description provided for @withdrawConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruyu geri çek?'**
  String get withdrawConfirmTitle;

  /// No description provided for @withdrawConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'\"{position}\" ilanına yaptığın başvuru geri çekilecek.'**
  String withdrawConfirmBody(String position);

  /// No description provided for @withdrawSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru geri çekildi'**
  String get withdrawSuccess;

  /// No description provided for @applicantDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuran'**
  String get applicantDetailTitle;

  /// No description provided for @updateStatusAction.
  ///
  /// In tr, this message translates to:
  /// **'Durumu güncelle'**
  String get updateStatusAction;

  /// No description provided for @statusUpdateSheetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Durumu güncelle'**
  String get statusUpdateSheetTitle;

  /// No description provided for @statusUpdatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Durum güncellendi'**
  String get statusUpdatedSuccess;

  /// No description provided for @statusTimelineApplied.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruldu'**
  String get statusTimelineApplied;

  /// No description provided for @statusTimelineReview.
  ///
  /// In tr, this message translates to:
  /// **'İncelemede'**
  String get statusTimelineReview;

  /// No description provided for @statusTimelineResult.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç'**
  String get statusTimelineResult;

  /// No description provided for @labelClassYear.
  ///
  /// In tr, this message translates to:
  /// **'Sınıf'**
  String get labelClassYear;

  /// No description provided for @labelGpa.
  ///
  /// In tr, this message translates to:
  /// **'Not ortalaması'**
  String get labelGpa;

  /// No description provided for @labelAppliedDate.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru tarihi'**
  String get labelAppliedDate;

  /// No description provided for @labelUniversity.
  ///
  /// In tr, this message translates to:
  /// **'Üniversite'**
  String get labelUniversity;

  /// No description provided for @labelDegreeLevel.
  ///
  /// In tr, this message translates to:
  /// **'Derece düzeyi'**
  String get labelDegreeLevel;

  /// No description provided for @labelPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get labelPhone;

  /// No description provided for @labelExpectedGraduation.
  ///
  /// In tr, this message translates to:
  /// **'Beklenen mezuniyet'**
  String get labelExpectedGraduation;

  /// No description provided for @labelAcademicTitle.
  ///
  /// In tr, this message translates to:
  /// **'Akademik unvan'**
  String get labelAcademicTitle;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @editProfileAction.
  ///
  /// In tr, this message translates to:
  /// **'Profili düzenle'**
  String get editProfileAction;

  /// No description provided for @logoutAction.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get logoutAction;

  /// No description provided for @changePasswordAction.
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştir'**
  String get changePasswordAction;

  /// No description provided for @sectionSkills.
  ///
  /// In tr, this message translates to:
  /// **'Yetenekler'**
  String get sectionSkills;

  /// No description provided for @sectionLanguages.
  ///
  /// In tr, this message translates to:
  /// **'Diller'**
  String get sectionLanguages;

  /// No description provided for @sectionExperience.
  ///
  /// In tr, this message translates to:
  /// **'Deneyim'**
  String get sectionExperience;

  /// No description provided for @sectionEducation.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim'**
  String get sectionEducation;

  /// No description provided for @emptySectionGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Henüz eklenmemiş'**
  String get emptySectionGeneric;

  /// No description provided for @profileErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil yüklenemedi'**
  String get profileErrorTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profili düzenle'**
  String get editProfileTitle;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi'**
  String get profileSavedSuccess;

  /// No description provided for @manageSkillsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yetenekler'**
  String get manageSkillsTitle;

  /// No description provided for @searchSkillsHint.
  ///
  /// In tr, this message translates to:
  /// **'Yetenek ara'**
  String get searchSkillsHint;

  /// No description provided for @yourSkills.
  ///
  /// In tr, this message translates to:
  /// **'Yetenekleriniz'**
  String get yourSkills;

  /// No description provided for @noSkillsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yetenek eklenmemiş'**
  String get noSkillsYet;

  /// No description provided for @skillsCatalogEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen yetenek yok'**
  String get skillsCatalogEmpty;

  /// No description provided for @manageLanguagesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Diller'**
  String get manageLanguagesTitle;

  /// No description provided for @searchLanguagesHint.
  ///
  /// In tr, this message translates to:
  /// **'Dil ara'**
  String get searchLanguagesHint;

  /// No description provided for @yourLanguages.
  ///
  /// In tr, this message translates to:
  /// **'Dilleriniz'**
  String get yourLanguages;

  /// No description provided for @noLanguagesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz dil eklenmemiş'**
  String get noLanguagesYet;

  /// No description provided for @selectLevel.
  ///
  /// In tr, this message translates to:
  /// **'Seviye seç'**
  String get selectLevel;

  /// No description provided for @levelBeginner.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get levelAdvanced;

  /// No description provided for @levelNative.
  ///
  /// In tr, this message translates to:
  /// **'Anadil'**
  String get levelNative;

  /// No description provided for @experienceAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Deneyim ekle'**
  String get experienceAddTitle;

  /// No description provided for @experienceEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Deneyimi düzenle'**
  String get experienceEditTitle;

  /// No description provided for @experienceEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz deneyim eklenmemiş'**
  String get experienceEmpty;

  /// No description provided for @deleteExperienceConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu deneyimi sil?'**
  String get deleteExperienceConfirm;

  /// No description provided for @fieldCompany.
  ///
  /// In tr, this message translates to:
  /// **'Şirket'**
  String get fieldCompany;

  /// No description provided for @fieldPosition.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon'**
  String get fieldPosition;

  /// No description provided for @fieldDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get fieldDescription;

  /// No description provided for @fieldStartDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç tarihi'**
  String get fieldStartDate;

  /// No description provided for @fieldEndDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş tarihi'**
  String get fieldEndDate;

  /// No description provided for @stillHere.
  ///
  /// In tr, this message translates to:
  /// **'Halen burada'**
  String get stillHere;

  /// No description provided for @ongoing.
  ///
  /// In tr, this message translates to:
  /// **'Devam ediyor'**
  String get ongoing;

  /// No description provided for @educationAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim ekle'**
  String get educationAddTitle;

  /// No description provided for @educationEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eğitimi düzenle'**
  String get educationEditTitle;

  /// No description provided for @educationEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz eğitim eklenmemiş'**
  String get educationEmpty;

  /// No description provided for @deleteEducationConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu eğitimi sil?'**
  String get deleteEducationConfirm;

  /// No description provided for @fieldPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get fieldPhone;

  /// No description provided for @fieldUniversity.
  ///
  /// In tr, this message translates to:
  /// **'Üniversite'**
  String get fieldUniversity;

  /// No description provided for @fieldDegreeLevel.
  ///
  /// In tr, this message translates to:
  /// **'Derece düzeyi'**
  String get fieldDegreeLevel;

  /// No description provided for @fieldClassYear.
  ///
  /// In tr, this message translates to:
  /// **'Sınıf'**
  String get fieldClassYear;

  /// No description provided for @fieldGpa.
  ///
  /// In tr, this message translates to:
  /// **'Not ortalaması'**
  String get fieldGpa;

  /// No description provided for @fieldExpectedGraduation.
  ///
  /// In tr, this message translates to:
  /// **'Beklenen mezuniyet tarihi'**
  String get fieldExpectedGraduation;

  /// No description provided for @fieldAcademicTitle.
  ///
  /// In tr, this message translates to:
  /// **'Akademik unvan'**
  String get fieldAcademicTitle;

  /// No description provided for @pickDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seç'**
  String get pickDate;

  /// No description provided for @notProvided.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmemiş'**
  String get notProvided;

  /// No description provided for @valGpaRange.
  ///
  /// In tr, this message translates to:
  /// **'0 ile 4 arasında bir değer gir'**
  String get valGpaRange;

  /// No description provided for @valClassYear.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir sınıf gir'**
  String get valClassYear;

  /// No description provided for @catCourseAssistant.
  ///
  /// In tr, this message translates to:
  /// **'Ders Asistanı'**
  String get catCourseAssistant;

  /// No description provided for @catLabAssistant.
  ///
  /// In tr, this message translates to:
  /// **'Laboratuvar Asistanı'**
  String get catLabAssistant;

  /// No description provided for @catResearchAssistant.
  ///
  /// In tr, this message translates to:
  /// **'Araştırma Asistanı'**
  String get catResearchAssistant;

  /// No description provided for @catOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get catOther;

  /// No description provided for @sortNewest.
  ///
  /// In tr, this message translates to:
  /// **'En yeni'**
  String get sortNewest;

  /// No description provided for @sortDeadlineSoonest.
  ///
  /// In tr, this message translates to:
  /// **'Son tarihe göre'**
  String get sortDeadlineSoonest;

  /// No description provided for @sortGpaHighToLow.
  ///
  /// In tr, this message translates to:
  /// **'Ortalaması yüksekten düşüğe'**
  String get sortGpaHighToLow;

  /// No description provided for @filterSheetTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlanları filtrele'**
  String get filterSheetTitle;

  /// No description provided for @filterCategory.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get filterCategory;

  /// No description provided for @filterSortBy.
  ///
  /// In tr, this message translates to:
  /// **'Sırala'**
  String get filterSortBy;

  /// No description provided for @filterReset.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get filterReset;

  /// No description provided for @filterApply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get filterApply;

  /// No description provided for @filterDeptHint.
  ///
  /// In tr, this message translates to:
  /// **'Ör. Bilgisayar Mühendisliği'**
  String get filterDeptHint;

  /// No description provided for @filterDeptChip.
  ///
  /// In tr, this message translates to:
  /// **'Böl: {dept}'**
  String filterDeptChip(String dept);

  /// No description provided for @detailAboutPosition.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon hakkında'**
  String get detailAboutPosition;

  /// No description provided for @detailPostedBy.
  ///
  /// In tr, this message translates to:
  /// **'İlanı veren'**
  String get detailPostedBy;

  /// No description provided for @detailTimeline.
  ///
  /// In tr, this message translates to:
  /// **'Zaman çizelgesi'**
  String get detailTimeline;

  /// No description provided for @detailPostedLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yayınlandı'**
  String get detailPostedLabel;

  /// No description provided for @applicationDeadlineLabel.
  ///
  /// In tr, this message translates to:
  /// **'Son başvuru tarihi'**
  String get applicationDeadlineLabel;

  /// No description provided for @applicantsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başvuranlar'**
  String get applicantsLabel;

  /// No description provided for @copyLinkTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı kopyala'**
  String get copyLinkTooltip;

  /// No description provided for @linkCopiedMsg.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı kopyalandı'**
  String get linkCopiedMsg;

  /// No description provided for @applicationSubmittedMsg.
  ///
  /// In tr, this message translates to:
  /// **'Başvurun gönderildi'**
  String get applicationSubmittedMsg;

  /// No description provided for @alreadyAppliedMsg.
  ///
  /// In tr, this message translates to:
  /// **'Bu ilana zaten başvurdunuz'**
  String get alreadyAppliedMsg;

  /// No description provided for @postingNoLongerAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu ilan artık mevcut değil'**
  String get postingNoLongerAvailable;

  /// No description provided for @viewApplicantsAction.
  ///
  /// In tr, this message translates to:
  /// **'Başvuranları gör'**
  String get viewApplicantsAction;

  /// No description provided for @couldNotLoadPosting.
  ///
  /// In tr, this message translates to:
  /// **'İlan yüklenemedi'**
  String get couldNotLoadPosting;

  /// No description provided for @thisPostingNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu ilan bulunamadı.'**
  String get thisPostingNotFound;

  /// No description provided for @actionGoBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get actionGoBack;

  /// No description provided for @applyButtonIdle.
  ///
  /// In tr, this message translates to:
  /// **'Başvur'**
  String get applyButtonIdle;

  /// No description provided for @applyButtonApplied.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruldu'**
  String get applyButtonApplied;

  /// No description provided for @applyButtonExpired.
  ///
  /// In tr, this message translates to:
  /// **'Son tarih geçti'**
  String get applyButtonExpired;

  /// No description provided for @applicantsScreenTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuranlar'**
  String get applicantsScreenTitle;

  /// No description provided for @couldNotLoadApplicants.
  ///
  /// In tr, this message translates to:
  /// **'Başvuranlar yüklenemedi'**
  String get couldNotLoadApplicants;

  /// No description provided for @noAccessToPosting.
  ///
  /// In tr, this message translates to:
  /// **'Bu ilana erişim izniniz yok'**
  String get noAccessToPosting;

  /// No description provided for @postingNotFound.
  ///
  /// In tr, this message translates to:
  /// **'İlan bulunamadı'**
  String get postingNotFound;

  /// No description provided for @noApplicantsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz başvuran yok'**
  String get noApplicantsYet;

  /// No description provided for @applicantsWillAppear.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenciler başvurdukça burada görünecek.'**
  String get applicantsWillAppear;

  /// No description provided for @jobFormNewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İlan'**
  String get jobFormNewTitle;

  /// No description provided for @jobFormEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlanı Düzenle'**
  String get jobFormEditTitle;

  /// No description provided for @positionHint.
  ///
  /// In tr, this message translates to:
  /// **'Ör. CSE2024 Öğretim Görevlisi'**
  String get positionHint;

  /// No description provided for @jobPositionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon gerekli'**
  String get jobPositionRequired;

  /// No description provided for @jobPositionTooLong.
  ///
  /// In tr, this message translates to:
  /// **'{max} karakterin altında tutun'**
  String jobPositionTooLong(int max);

  /// No description provided for @chooseCategoryPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Kategori seçin'**
  String get chooseCategoryPrompt;

  /// No description provided for @deptHint.
  ///
  /// In tr, this message translates to:
  /// **'Ör. Bilgisayar Mühendisliği'**
  String get deptHint;

  /// No description provided for @deptRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm gerekli'**
  String get deptRequired;

  /// No description provided for @descriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Sorumluluklar, gereksinimler, saatler…'**
  String get descriptionHint;

  /// No description provided for @descriptionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama gerekli'**
  String get descriptionRequired;

  /// No description provided for @descriptionTooLong.
  ///
  /// In tr, this message translates to:
  /// **'{max} karakterin altında tutun'**
  String descriptionTooLong(int max);

  /// No description provided for @selectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seçin'**
  String get selectDate;

  /// No description provided for @deadlineRequired.
  ///
  /// In tr, this message translates to:
  /// **'Son tarih gerekli'**
  String get deadlineRequired;

  /// No description provided for @publishAction.
  ///
  /// In tr, this message translates to:
  /// **'Yayınla'**
  String get publishAction;

  /// No description provided for @saveChangesAction.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri kaydet'**
  String get saveChangesAction;

  /// No description provided for @changesSavedMsg.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kaydedildi'**
  String get changesSavedMsg;

  /// No description provided for @postingPublishedMsg.
  ///
  /// In tr, this message translates to:
  /// **'İlan yayınlandı'**
  String get postingPublishedMsg;

  /// No description provided for @navActivePostings.
  ///
  /// In tr, this message translates to:
  /// **'Aktif İlanlar'**
  String get navActivePostings;

  /// No description provided for @navInactivePostings.
  ///
  /// In tr, this message translates to:
  /// **'Pasif İlanlar'**
  String get navInactivePostings;

  /// No description provided for @newPostingTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yeni İlan'**
  String get newPostingTooltip;

  /// No description provided for @actionCreatePosting.
  ///
  /// In tr, this message translates to:
  /// **'İlan oluştur'**
  String get actionCreatePosting;

  /// No description provided for @myJobsErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlanların yüklenemedi'**
  String get myJobsErrorTitle;

  /// No description provided for @myJobsEmptyActiveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif ilanın yok'**
  String get myJobsEmptyActiveTitle;

  /// No description provided for @myJobsEmptyActiveSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk iş ilanını oluştur.'**
  String get myJobsEmptyActiveSubtitle;

  /// No description provided for @myJobsEmptyInactiveTitle.
  ///
  /// In tr, this message translates to:
  /// **'Pasif ilanın yok'**
  String get myJobsEmptyInactiveTitle;

  /// No description provided for @myJobsEmptyInactiveSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kapanan veya süresi dolan ilanlar burada görünür.'**
  String get myJobsEmptyInactiveSubtitle;

  /// No description provided for @closePostingTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlanı kapat?'**
  String get closePostingTitle;

  /// No description provided for @closePostingBody.
  ///
  /// In tr, this message translates to:
  /// **'\"{position}\" ilanına artık başvuru yapılamayacak. Mevcut başvurular korunur.'**
  String closePostingBody(String position);

  /// No description provided for @actionClosePosting.
  ///
  /// In tr, this message translates to:
  /// **'İlanı kapat'**
  String get actionClosePosting;

  /// No description provided for @postingClosedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'İlan kapatıldı'**
  String get postingClosedSuccess;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'tr':
      return L10nTr();
  }

  throw FlutterError(
      'L10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
