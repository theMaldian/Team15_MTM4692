// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class L10nTr extends L10n {
  L10nTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'YTÜ Asistan';

  @override
  String get appTagline => 'YTÜ İşe Alım Sistemi';

  @override
  String get languageTurkish => 'TR';

  @override
  String get languageEnglish => 'EN';

  @override
  String get toggleLanguage => 'Dili değiştir';

  @override
  String get fieldEmail => 'E-posta';

  @override
  String get fieldPassword => 'Şifre';

  @override
  String get emailHint => 'ad@std.yildiz.edu.tr';

  @override
  String get loginTitle => 'Tekrar hoş geldin';

  @override
  String get loginSubtitle => 'Devam etmek için giriş yap';

  @override
  String get actionSignIn => 'Giriş yap';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String get dividerOr => 'veya';

  @override
  String get actionCreateAccount => 'Hesap oluştur';

  @override
  String get noAccountQuestion => 'Hesabın yok mu? ';

  @override
  String get actionSignUp => 'Kayıt ol';

  @override
  String get snackInvalidCredentials => 'E-posta veya şifre hatalı';

  @override
  String get registerTitle => 'Hesap oluştur';

  @override
  String get registerSubtitle =>
      'YTÜ e-postanı kullan. Rolün, kayıt olduğun e-posta alan adına göre belirlenir.';

  @override
  String get fieldFirstName => 'Ad';

  @override
  String get fieldLastName => 'Soyad';

  @override
  String get fieldFaculty => 'Fakülte';

  @override
  String get fieldDepartment => 'Bölüm';

  @override
  String get fieldPasswordConfirm => 'Şifre tekrar';

  @override
  String get actionRegister => 'Kayıt ol';

  @override
  String get chooseFaculty => 'Fakülteni seç';

  @override
  String get chooseDepartment => 'Bölümünü seç';

  @override
  String get selectFacultyFirst => 'Önce fakülteyi seç';

  @override
  String get registerNote =>
      'Not: fakülte ve bölüm, giriş yaptıktan sonra profiline kaydedilir.';

  @override
  String get haveAccountQuestion => 'Zaten hesabın var mı? ';

  @override
  String get snackAccountCreated =>
      'Hesap oluşturuldu. Doğrulama kodu için e-postanı kontrol et.';

  @override
  String get snackEmailExists => 'Bu e-posta ile bir hesap zaten var';

  @override
  String get roleStudent => 'Öğrenci';

  @override
  String get roleProfessor => 'Akademisyen';

  @override
  String get verifyTitle => 'E-postanı doğrula';

  @override
  String verifySubtitle(String email) {
    return '$email adresine 6 haneli bir kod gönderdik. Hesabını etkinleştirmek için aşağıya gir.';
  }

  @override
  String get fieldVerificationCode => 'Doğrulama kodu';

  @override
  String get hintSixDigitCode => '6 haneli kod';

  @override
  String get actionVerify => 'E-postayı doğrula';

  @override
  String get noCodeQuestion => 'Kod gelmedi mi? ';

  @override
  String get actionResend => 'Tekrar gönder';

  @override
  String resendIn(int seconds) {
    return '$seconds sn sonra tekrar';
  }

  @override
  String get codeExpiresNote => 'Kod 10 dakika sonra geçersiz olur.';

  @override
  String get snackEmailVerified =>
      'E-posta doğrulandı. Artık giriş yapabilirsin.';

  @override
  String get snackCodeSent => 'Doğrulama kodu gönderildi.';

  @override
  String get forgotTitle => 'Şifreni mi unuttun';

  @override
  String get forgotSubtitle =>
      'YTÜ e-postanı gir, şifreni sıfırlaman için sana bir kod gönderelim.';

  @override
  String get actionSendCode => 'Kod gönder';

  @override
  String get checkEmailTitle => 'E-postanı kontrol et';

  @override
  String checkEmailSubtitle(String email) {
    return '$email için bir hesap varsa, 6 haneli bir sıfırlama kodu gönderdik. Kod 10 dakika içinde geçersiz olur.';
  }

  @override
  String get actionEnterResetCode => 'Sıfırlama kodunu gir';

  @override
  String get actionBackToSignIn => 'Girişe dön';

  @override
  String get resetTitle => 'Şifreyi sıfırla';

  @override
  String get resetSubtitle =>
      'E-postana gönderdiğimiz 6 haneli kodu ve yeni bir şifre gir.';

  @override
  String get fieldResetCode => 'Sıfırlama kodu';

  @override
  String get fieldNewPassword => 'Yeni şifre';

  @override
  String get fieldConfirmNewPassword => 'Yeni şifre tekrar';

  @override
  String get actionReset => 'Şifreyi sıfırla';

  @override
  String get snackPasswordReset =>
      'Şifre sıfırlandı. Artık giriş yapabilirsin.';

  @override
  String get pwHintLength => 'En az 8 karakter';

  @override
  String get pwHintLetter => 'Bir harf içerir';

  @override
  String get pwHintNumber => 'Bir rakam içerir';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get valEmailRequired => 'E-posta gerekli';

  @override
  String get valEmailInvalid => 'Geçerli bir e-posta adresi gir';

  @override
  String valEmailDomain(String student, String professor) {
    return 'YTÜ e-postanı kullan ($student veya $professor)';
  }

  @override
  String get valPasswordRequired => 'Şifre gerekli';

  @override
  String get valPasswordMin => 'Şifre en az 8 karakter olmalı';

  @override
  String get valPasswordLetter => 'Şifre en az bir harf içermeli';

  @override
  String get valPasswordNumber => 'Şifre en az bir rakam içermeli';

  @override
  String get valRequired => 'Bu alan zorunlu';

  @override
  String get valMinChars => 'En az 2 karakter olmalı';

  @override
  String get valMaxChars => 'En fazla 50 karakter olmalı';

  @override
  String get valCodeRequired => 'Kod gerekli';

  @override
  String get valCodeSixDigits => '6 haneli kodu gir';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get jobsTitle => 'Fırsatlar';

  @override
  String get filterTooltip => 'Filtrele';

  @override
  String get jobSeeDetails => 'Detayları gör';

  @override
  String get emptyNoPostingsTitle => 'Açık ilan yok';

  @override
  String get emptyNoPostingsSubtitle =>
      'Yeni fırsatlar için daha sonra tekrar bak.';

  @override
  String get emptyNoMatchTitle => 'Eşleşen ilan yok';

  @override
  String get emptyNoMatchSubtitle =>
      'Filtrelerini temizlemeyi veya değiştirmeyi dene.';

  @override
  String get actionClearFilters => 'Filtreleri temizle';

  @override
  String get errorLoadTitle => 'İlanlar yüklenemedi';

  @override
  String get errorLoadSubtitle =>
      'Fırsatlar yüklenirken bir şeyler ters gitti.';

  @override
  String get actionRetry => 'Tekrar dene';

  @override
  String get studentOnlyTitle => 'Öğrencilere özel akış';

  @override
  String get studentOnlySubtitle =>
      'Aktif ilanlara göz atmak öğrencilere açıktır. İlanlarını yönetmek için \"İlanlarım\" bölümünü kullan.';

  @override
  String get deniedForStudents => 'Öğrenciler için kullanılamaz';

  @override
  String get statusActive => 'Aktif';

  @override
  String get statusClosed => 'Kapandı';

  @override
  String get statusExpired => 'Süresi doldu';

  @override
  String get deadlineExpired => 'Süresi doldu';

  @override
  String get deadlineDueToday => 'Bugün son';

  @override
  String deadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String deadlineDue(String date) {
    return 'Son: $date';
  }

  @override
  String applicantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count başvuru',
    );
    return '$_temp0';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bekliyor',
    );
    return '$_temp0';
  }

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get errorConnection =>
      'Bağlantı hatası. İnternetini kontrol edip tekrar dene.';

  @override
  String get errorForbidden => 'Bu işlem için yetkin yok';

  @override
  String get errorNotFound => 'Bulunamadı';

  @override
  String get navOpportunities => 'Fırsatlar';

  @override
  String get navApplications => 'Başvurularım';

  @override
  String get navProfile => 'Profil';

  @override
  String get navMyPostings => 'İlanlarım';

  @override
  String get navExplore => 'Keşfet';

  @override
  String get actionAdd => 'Ekle';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionConfirm => 'Onayla';

  @override
  String get actionViewJob => 'İlanı gör';

  @override
  String get appStatusPending => 'Beklemede';

  @override
  String get appStatusApproved => 'Onaylandı';

  @override
  String get appStatusRejected => 'Reddedildi';

  @override
  String get myApplicationsTitle => 'Başvurularım';

  @override
  String get applicationsEmptyTitle => 'Henüz başvurun yok';

  @override
  String get applicationsEmptySubtitle =>
      'Başvurduğun ilanlar burada görünecek.';

  @override
  String get applicationsErrorTitle => 'Başvurular yüklenemedi';

  @override
  String appliedOn(String date) {
    return '$date tarihinde başvuruldu';
  }

  @override
  String get withdrawAction => 'Başvuruyu geri çek';

  @override
  String get withdrawConfirmTitle => 'Başvuruyu geri çek?';

  @override
  String withdrawConfirmBody(String position) {
    return '\"$position\" ilanına yaptığın başvuru geri çekilecek.';
  }

  @override
  String get withdrawSuccess => 'Başvuru geri çekildi';

  @override
  String get applicantDetailTitle => 'Başvuran';

  @override
  String get updateStatusAction => 'Durumu güncelle';

  @override
  String get statusUpdateSheetTitle => 'Durumu güncelle';

  @override
  String get statusUpdatedSuccess => 'Durum güncellendi';

  @override
  String get statusTimelineApplied => 'Başvuruldu';

  @override
  String get statusTimelineReview => 'İncelemede';

  @override
  String get statusTimelineResult => 'Sonuç';

  @override
  String get labelClassYear => 'Sınıf';

  @override
  String get labelGpa => 'Not ortalaması';

  @override
  String get labelAppliedDate => 'Başvuru tarihi';

  @override
  String get labelUniversity => 'Üniversite';

  @override
  String get labelDegreeLevel => 'Derece düzeyi';

  @override
  String get labelPhone => 'Telefon';

  @override
  String get labelExpectedGraduation => 'Beklenen mezuniyet';

  @override
  String get labelAcademicTitle => 'Akademik unvan';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfileAction => 'Profili düzenle';

  @override
  String get logoutAction => 'Çıkış yap';

  @override
  String get changePasswordAction => 'Şifre değiştir';

  @override
  String get sectionSkills => 'Yetenekler';

  @override
  String get sectionLanguages => 'Diller';

  @override
  String get sectionExperience => 'Deneyim';

  @override
  String get sectionEducation => 'Eğitim';

  @override
  String get emptySectionGeneric => 'Henüz eklenmemiş';

  @override
  String get profileErrorTitle => 'Profil yüklenemedi';

  @override
  String get editProfileTitle => 'Profili düzenle';

  @override
  String get profileSavedSuccess => 'Profil güncellendi';

  @override
  String get manageSkillsTitle => 'Yetenekler';

  @override
  String get searchSkillsHint => 'Yetenek ara';

  @override
  String get yourSkills => 'Yetenekleriniz';

  @override
  String get noSkillsYet => 'Henüz yetenek eklenmemiş';

  @override
  String get skillsCatalogEmpty => 'Eşleşen yetenek yok';

  @override
  String get manageLanguagesTitle => 'Diller';

  @override
  String get searchLanguagesHint => 'Dil ara';

  @override
  String get yourLanguages => 'Dilleriniz';

  @override
  String get noLanguagesYet => 'Henüz dil eklenmemiş';

  @override
  String get selectLevel => 'Seviye seç';

  @override
  String get levelBeginner => 'Başlangıç';

  @override
  String get levelIntermediate => 'Orta';

  @override
  String get levelAdvanced => 'İleri';

  @override
  String get levelNative => 'Anadil';

  @override
  String get experienceAddTitle => 'Deneyim ekle';

  @override
  String get experienceEditTitle => 'Deneyimi düzenle';

  @override
  String get experienceEmpty => 'Henüz deneyim eklenmemiş';

  @override
  String get deleteExperienceConfirm => 'Bu deneyimi sil?';

  @override
  String get fieldCompany => 'Şirket';

  @override
  String get fieldPosition => 'Pozisyon';

  @override
  String get fieldDescription => 'Açıklama';

  @override
  String get fieldStartDate => 'Başlangıç tarihi';

  @override
  String get fieldEndDate => 'Bitiş tarihi';

  @override
  String get stillHere => 'Halen burada';

  @override
  String get ongoing => 'Devam ediyor';

  @override
  String get educationAddTitle => 'Eğitim ekle';

  @override
  String get educationEditTitle => 'Eğitimi düzenle';

  @override
  String get educationEmpty => 'Henüz eğitim eklenmemiş';

  @override
  String get deleteEducationConfirm => 'Bu eğitimi sil?';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get fieldUniversity => 'Üniversite';

  @override
  String get fieldDegreeLevel => 'Derece düzeyi';

  @override
  String get fieldClassYear => 'Sınıf';

  @override
  String get fieldGpa => 'Not ortalaması';

  @override
  String get fieldExpectedGraduation => 'Beklenen mezuniyet tarihi';

  @override
  String get fieldAcademicTitle => 'Akademik unvan';

  @override
  String get pickDate => 'Tarih seç';

  @override
  String get notProvided => 'Belirtilmemiş';

  @override
  String get valGpaRange => '0 ile 4 arasında bir değer gir';

  @override
  String get valClassYear => 'Geçerli bir sınıf gir';

  @override
  String get catCourseAssistant => 'Ders Asistanı';

  @override
  String get catLabAssistant => 'Laboratuvar Asistanı';

  @override
  String get catResearchAssistant => 'Araştırma Asistanı';

  @override
  String get catOther => 'Diğer';

  @override
  String get sortNewest => 'En yeni';

  @override
  String get sortDeadlineSoonest => 'Son tarihe göre';

  @override
  String get sortGpaHighToLow => 'Ortalaması yüksekten düşüğe';

  @override
  String get filterSheetTitle => 'İlanları filtrele';

  @override
  String get filterCategory => 'Kategori';

  @override
  String get filterSortBy => 'Sırala';

  @override
  String get filterReset => 'Sıfırla';

  @override
  String get filterApply => 'Uygula';

  @override
  String get filterDeptHint => 'Ör. Bilgisayar Mühendisliği';

  @override
  String filterDeptChip(String dept) {
    return 'Böl: $dept';
  }

  @override
  String get detailAboutPosition => 'Pozisyon hakkında';

  @override
  String get detailPostedBy => 'İlanı veren';

  @override
  String get detailTimeline => 'Zaman çizelgesi';

  @override
  String get detailPostedLabel => 'Yayınlandı';

  @override
  String get applicationDeadlineLabel => 'Son başvuru tarihi';

  @override
  String get applicantsLabel => 'Başvuranlar';

  @override
  String get copyLinkTooltip => 'Bağlantıyı kopyala';

  @override
  String get linkCopiedMsg => 'Bağlantı kopyalandı';

  @override
  String get applicationSubmittedMsg => 'Başvurun gönderildi';

  @override
  String get alreadyAppliedMsg => 'Bu ilana zaten başvurdunuz';

  @override
  String get postingNoLongerAvailable => 'Bu ilan artık mevcut değil';

  @override
  String get viewApplicantsAction => 'Başvuranları gör';

  @override
  String get couldNotLoadPosting => 'İlan yüklenemedi';

  @override
  String get thisPostingNotFound => 'Bu ilan bulunamadı.';

  @override
  String get actionGoBack => 'Geri dön';

  @override
  String get applyButtonIdle => 'Başvur';

  @override
  String get applyButtonApplied => 'Başvuruldu';

  @override
  String get applyButtonExpired => 'Son tarih geçti';

  @override
  String get applicantsScreenTitle => 'Başvuranlar';

  @override
  String get couldNotLoadApplicants => 'Başvuranlar yüklenemedi';

  @override
  String get noAccessToPosting => 'Bu ilana erişim izniniz yok';

  @override
  String get postingNotFound => 'İlan bulunamadı';

  @override
  String get noApplicantsYet => 'Henüz başvuran yok';

  @override
  String get applicantsWillAppear => 'Öğrenciler başvurdukça burada görünecek.';

  @override
  String get jobFormNewTitle => 'Yeni İlan';

  @override
  String get jobFormEditTitle => 'İlanı Düzenle';

  @override
  String get positionHint => 'Ör. CSE2024 Öğretim Görevlisi';

  @override
  String get jobPositionRequired => 'Pozisyon gerekli';

  @override
  String jobPositionTooLong(int max) {
    return '$max karakterin altında tutun';
  }

  @override
  String get chooseCategoryPrompt => 'Kategori seçin';

  @override
  String get deptHint => 'Ör. Bilgisayar Mühendisliği';

  @override
  String get deptRequired => 'Bölüm gerekli';

  @override
  String get descriptionHint => 'Sorumluluklar, gereksinimler, saatler…';

  @override
  String get descriptionRequired => 'Açıklama gerekli';

  @override
  String descriptionTooLong(int max) {
    return '$max karakterin altında tutun';
  }

  @override
  String get selectDate => 'Tarih seçin';

  @override
  String get deadlineRequired => 'Son tarih gerekli';

  @override
  String get publishAction => 'Yayınla';

  @override
  String get saveChangesAction => 'Değişiklikleri kaydet';

  @override
  String get changesSavedMsg => 'Değişiklikler kaydedildi';

  @override
  String get postingPublishedMsg => 'İlan yayınlandı';

  @override
  String get navActivePostings => 'Aktif İlanlar';

  @override
  String get navInactivePostings => 'Pasif İlanlar';

  @override
  String get newPostingTooltip => 'Yeni İlan';

  @override
  String get actionCreatePosting => 'İlan oluştur';

  @override
  String get myJobsErrorTitle => 'İlanların yüklenemedi';

  @override
  String get myJobsEmptyActiveTitle => 'Aktif ilanın yok';

  @override
  String get myJobsEmptyActiveSubtitle => 'İlk iş ilanını oluştur.';

  @override
  String get myJobsEmptyInactiveTitle => 'Pasif ilanın yok';

  @override
  String get myJobsEmptyInactiveSubtitle =>
      'Kapanan veya süresi dolan ilanlar burada görünür.';

  @override
  String get closePostingTitle => 'İlanı kapat?';

  @override
  String closePostingBody(String position) {
    return '\"$position\" ilanına artık başvuru yapılamayacak. Mevcut başvurular korunur.';
  }

  @override
  String get actionClosePosting => 'İlanı kapat';

  @override
  String get postingClosedSuccess => 'İlan kapatıldı';
}
