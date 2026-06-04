/// Static snapshot of YTU faculties and their departments (Turkish names).
///
/// The backend currently exposes no `/faculties` catalog endpoint, so this map
/// is hard-coded. It is intentionally a single source of truth: when an
/// endpoint becomes available, replace [kYtuFaculties] with a fetched map and
/// the register dropdowns keep working unchanged.
///
/// Each faculty includes a trailing "Diğer" (Other) entry as an escape hatch.
library;

const String kOtherDepartment = 'Diğer';

const Map<String, List<String>> kYtuFaculties = <String, List<String>>{
  'Kimya-Metalurji Fakültesi': <String>[
    'Matematik Mühendisliği',
    'Kimya Mühendisliği',
    'Metalurji ve Malzeme Mühendisliği',
    'Biyomühendislik',
    'Fizik',
    kOtherDepartment,
  ],
  'Elektrik-Elektronik Fakültesi': <String>[
    'Elektrik Mühendisliği',
    'Elektronik ve Haberleşme Mühendisliği',
    'Bilgisayar Mühendisliği',
    'Kontrol ve Otomasyon Mühendisliği',
    'Biyomedikal Mühendisliği',
    kOtherDepartment,
  ],
  'İnşaat Fakültesi': <String>[
    'İnşaat Mühendisliği',
    'Çevre Mühendisliği',
    'Harita Mühendisliği',
    kOtherDepartment,
  ],
  'Makine Fakültesi': <String>[
    'Makine Mühendisliği',
    'Endüstri Mühendisliği',
    'Mekatronik Mühendisliği',
    kOtherDepartment,
  ],
  'Mimarlık Fakültesi': <String>[
    'Mimarlık',
    'Şehir ve Bölge Planlama',
    kOtherDepartment,
  ],
  'Gemi İnşaatı ve Denizcilik Fakültesi': <String>[
    'Gemi İnşaatı ve Gemi Makineleri Mühendisliği',
    'Gemi Makineleri İşletme Mühendisliği',
    kOtherDepartment,
  ],
  'Fen-Edebiyat Fakültesi': <String>[
    'İstatistik',
    'Moleküler Biyoloji ve Genetik',
    'Türk Dili ve Edebiyatı',
    'Batı Dilleri ve Edebiyatı',
    'İnsan ve Toplum Bilimleri',
    kOtherDepartment,
  ],
  'İktisadi ve İdari Bilimler Fakültesi': <String>[
    'İktisat',
    'İşletme',
    'Siyaset Bilimi ve Uluslararası İlişkiler',
    kOtherDepartment,
  ],
  'Eğitim Fakültesi': <String>[
    'Bilgisayar ve Öğretim Teknolojileri Öğretmenliği',
    'Okul Öncesi Öğretmenliği',
    'Fen Bilgisi Öğretmenliği',
    'Matematik Öğretmenliği',
    kOtherDepartment,
  ],
  'Sanat ve Tasarım Fakültesi': <String>[
    'İletişim Tasarımı',
    'Müzik',
    'Sanat Yönetimi',
    'Fotoğraf ve Video',
    kOtherDepartment,
  ],
};

/// Faculty names in display order.
List<String> get kYtuFacultyNames => kYtuFaculties.keys.toList();

/// Departments for [faculty], or an empty list if unknown / not yet chosen.
List<String> departmentsForFaculty(String? faculty) =>
    faculty == null ? const <String>[] : (kYtuFaculties[faculty] ?? const <String>[]);
