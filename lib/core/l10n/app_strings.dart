enum AppLocale { ru, kk, en }

class S {
  S._();
  static AppLocale _locale = AppLocale.ru;
  static void setLocale(AppLocale locale) => _locale = locale;
  static AppLocale get locale => _locale;

  static String get signIn => _t({'ru': 'Войти', 'kk': 'Кіру', 'en': 'Sign In'});
  static String get register => _t({'ru': 'Регистрация', 'kk': 'Тіркелу', 'en': 'Register'});
  static String get email => _t({'ru': 'Email', 'kk': 'Email', 'en': 'Email'});
  static String get password => _t({'ru': 'Пароль', 'kk': 'Құпия сөз', 'en': 'Password'});
  static String get firstName => _t({'ru': 'Имя', 'kk': 'Аты', 'en': 'First name'});
  static String get lastName => _t({'ru': 'Фамилия', 'kk': 'Тегі', 'en': 'Last name'});
  static String get middleName => _t({'ru': 'Отчество', 'kk': 'Әкесінің аты', 'en': 'Middle name'});
  static String get phone => _t({'ru': 'Телефон', 'kk': 'Телефон', 'en': 'Phone'});
  static String get dateOfBirth => _t({'ru': 'Дата рождения', 'kk': 'Туған күні', 'en': 'Date of birth'});
  static String get gender => _t({'ru': 'Пол', 'kk': 'Жынысы', 'en': 'Gender'});
  static String get bloodType => _t({'ru': 'Группа крови', 'kk': 'Қан тобы', 'en': 'Blood type'});
  static String get height => _t({'ru': 'Рост (см)', 'kk': 'Бойы (см)', 'en': 'Height (cm)'});
  static String get weight => _t({'ru': 'Вес (кг)', 'kk': 'Салмағы (кг)', 'en': 'Weight (kg)'});
  static String get allergies => _t({'ru': 'Аллергии', 'kk': 'Аллергиялар', 'en': 'Allergies'});
  static String get chronicDiseases => _t({'ru': 'Хронические болезни', 'kk': 'Созылмалы аурулар', 'en': 'Chronic diseases'});
  static String get occupation => _t({'ru': 'Профессия', 'kk': 'Мамандығы', 'en': 'Occupation'});
  static String get address => _t({'ru': 'Адрес', 'kk': 'Мекенжайы', 'en': 'Address'});
  static String get emergencyContact => _t({'ru': 'Экстренный контакт', 'kk': 'Жедел байланыс', 'en': 'Emergency contact'});
  static String get contactName => _t({'ru': 'Имя контакта', 'kk': 'Байланыс аты', 'en': 'Contact name'});
  static String get contactPhone => _t({'ru': 'Телефон контакта', 'kk': 'Байланыс телефоны', 'en': 'Contact phone'});
  static String get insurance => _t({'ru': 'Страховка', 'kk': 'Сақтандыру', 'en': 'Insurance'});
  static String get insuranceNumber => _t({'ru': 'Номер страховки', 'kk': 'Сақтандыру нөмірі', 'en': 'Insurance number'});
  static String get language => _t({'ru': 'Язык', 'kk': 'Тіл', 'en': 'Language'});
  static String get saveChanges => _t({'ru': 'Сохранить', 'kk': 'Сақтау', 'en': 'Save Changes'});
  static String get editProfile => _t({'ru': 'Редактировать', 'kk': 'Өңдеу', 'en': 'Edit Profile'});
  static String get myProfile => _t({'ru': 'Мой профиль', 'kk': 'Менің профилім', 'en': 'My Profile'});
  static String get personalInfo => _t({'ru': 'Личная информация', 'kk': 'Жеке ақпарат', 'en': 'Personal Information'});
  static String get medicalInfo => _t({'ru': 'Медицинская информация', 'kk': 'Медициналық ақпарат', 'en': 'Medical Information'});
  static String get uploadXray => _t({'ru': 'Загрузить снимок', 'kk': 'Түсіру жүктеу', 'en': 'Upload X-Ray'});
  static String get analyzeXray => _t({'ru': 'Анализировать', 'kk': 'Талдау', 'en': 'Analyze X-Ray'});
  static String get myScans => _t({'ru': 'Мои снимки', 'kk': 'Менің түсірімдерім', 'en': 'My Scans'});
  static String get notifications => _t({'ru': 'Уведомления', 'kk': 'Хабарландырулар', 'en': 'Notifications'});
  static String get profile => _t({'ru': 'Профиль', 'kk': 'Профиль', 'en': 'Profile'});
  static String get logout => _t({'ru': 'Выйти', 'kk': 'Шығу', 'en': 'Logout'});
  static String get home => _t({'ru': 'Главная', 'kk': 'Басты бет', 'en': 'Home'});
  static String get reports => _t({'ru': 'Отчёты', 'kk': 'Есептер', 'en': 'Reports'});
  static String get appointments => _t({'ru': 'Приёмы', 'kk': 'Қабылдаулар', 'en': 'Appointments'});
  static String get createAccount => _t({'ru': 'Создать аккаунт', 'kk': 'Тіркелу', 'en': 'Create Account'});
  static String get alreadyHaveAccount => _t({'ru': 'Уже есть аккаунт? Войти', 'kk': 'Аккаунт бар ма? Кіру', 'en': 'Already have an account? Sign in'});
  static String get registerAsPatient => _t({'ru': 'Регистрация пациента', 'kk': 'Науқасты тіркеу', 'en': 'Register as a patient'});
  static String get required => _t({'ru': 'Обязательно', 'kk': 'Міндетті', 'en': 'Required'});
  static String get registrationSuccess => _t({'ru': 'Регистрация успешна!', 'kk': 'Тіркелу сәтті!', 'en': 'Registration successful!'});
  static String get goToLogin => _t({'ru': 'Перейти к входу', 'kk': 'Кіруге өту', 'en': 'Go to Login'});
  static String get noInternet => _t({'ru': 'Нет подключения к интернету', 'kk': 'Интернет байланысы жоқ', 'en': 'No internet connection'});
  static String get aiDiagnostics => _t({'ru': 'Медицинская диагностика на основе ИИ', 'kk': 'ЖИ негізіндегі медициналық диагностика', 'en': 'AI-Powered Medical Diagnostics'});
  static String get enterCredentials => _t({'ru': 'Введите данные для входа', 'kk': 'Кіру деректерін енгізіңіз', 'en': 'Enter your credentials to continue'});
  static String get emailRequired => _t({'ru': 'Email обязателен', 'kk': 'Email міндетті', 'en': 'Email is required'});
  static String get emailInvalid => _t({'ru': 'Введите корректный email', 'kk': 'Дұрыс email енгізіңіз', 'en': 'Enter a valid email'});
  static String get passwordRequired => _t({'ru': 'Пароль обязателен', 'kk': 'Құпия сөз міндетті', 'en': 'Password is required'});
  static String get passwordMin => _t({'ru': 'Мин. 6 символов', 'kk': 'Кем дегенде 6 таңба', 'en': 'Min 6 characters'});
  static String get noAccount => _t({'ru': 'Нет аккаунта? Зарегистрироваться', 'kk': 'Аккаунт жоқ па? Тіркелу', 'en': "Don't have an account? Register"});
  static String get phoneOptional => _t({'ru': 'Телефон (необязательно)', 'kk': 'Телефон (міндетті емес)', 'en': 'Phone number (optional)'});
  static String get invalidPhone => _t({'ru': 'Неверный номер телефона', 'kk': 'Телефон нөмірі қате', 'en': 'Invalid phone number'});
  static String get canSignIn => _t({'ru': 'Теперь вы можете войти', 'kk': 'Енді кіре аласыз', 'en': 'You can now sign in with your credentials.'});

  static String get goodDay => _t({'ru': 'Добрый день,', 'kk': 'Қайырлы күн,', 'en': 'Good day,'});
  static String get quickActions => _t({'ru': 'Быстрые действия', 'kk': 'Жылдам әрекеттер', 'en': 'Quick Actions'});
  static String get notificationsSubtitle => _t({'ru': 'Обновления и оповещения', 'kk': 'Жаңартулар мен ескертулер', 'en': 'Updates and alerts'});
  static String get howItWorks => _t({'ru': 'Как это работает', 'kk': 'Бұл қалай жұмыс істейді', 'en': 'How it works'});
  static String get signOut => _t({'ru': 'Выйти', 'kk': 'Шығу', 'en': 'Sign Out'});
  static String get uploadXraySubtitle => _t({'ru': 'ИИ анализ', 'kk': 'ЖИ талдауы', 'en': 'AI analysis'});
  static String get myXrays => _t({'ru': 'Мои снимки', 'kk': 'Менің түсірімдерім', 'en': 'My X-Rays'});
  static String get viewHistory => _t({'ru': 'История', 'kk': 'Тарих', 'en': 'View history'});
  static String get reportsSubtitle => _t({'ru': 'Отчёты врача', 'kk': 'Дәрігер есептері', 'en': 'Doctor reports'});
  static String get appointmentsSubtitle => _t({'ru': 'Запись и управление', 'kk': 'Жазылу және басқару', 'en': 'Book & manage'});
  static String get labResults => _t({'ru': 'Анализы', 'kk': 'Зертханалық нәтижелер', 'en': 'Lab Results'});
  static String get labResultsSubtitle => _t({'ru': 'Результаты тестов', 'kk': 'Тест нәтижелері', 'en': 'Test results'});
  static String get profileSubtitle => _t({'ru': 'Мед. информация', 'kk': 'Мед. ақпарат', 'en': 'Medical info'});
  static String get comingSoon => _t({'ru': 'Скоро', 'kk': 'Жақында', 'en': 'Coming soon'});
  static String get infoBannerPatient => _t({'ru': 'Загрузите рентген и получите ИИ-диагноз за секунды.', 'kk': 'Рентген жүктеп, секундтар ішінде ЖИ диагнозын алыңыз.', 'en': 'Upload a chest X-ray and receive an AI-powered diagnosis in seconds.'});
  static String get infoBannerDoctor => _t({'ru': 'Просматривайте назначенные снимки, подтверждайте ИИ результаты.', 'kk': 'Тағайындалған түсірімдерді қарап, ЖИ нәтижелерін растаңыз.', 'en': 'Review assigned X-ray analyses and validate AI results.'});
  static String get infoBannerAdmin => _t({'ru': 'Управляйте пользователями и следите за активностью платформы.', 'kk': 'Пайдаланушыларды басқарып, платформа белсенділігін бақылаңыз.', 'en': 'Manage users and monitor platform activity.'});

  static String get analysisResult => _t({'ru': 'Результат анализа', 'kk': 'Талдау нәтижесі', 'en': 'Analysis Result'});
  static String get statusLabel => _t({'ru': 'Статус', 'kk': 'Мәртебесі', 'en': 'Status'});
  static String get uploadedLabel => _t({'ru': 'Загружено', 'kk': 'Жүктелді', 'en': 'Uploaded'});
  static String get queuedForAnalysis => _t({'ru': 'В очереди на анализ', 'kk': 'Талдау кезегінде', 'en': 'Queued for analysis'});
  static String get aiAnalyzing => _t({'ru': 'ИИ анализирует снимок', 'kk': 'ЖИ түсірімді талдауда', 'en': 'AI is analyzing your X-ray'});
  static String get analysisTime => _t({'ru': 'Обычно занимает 10–30 секунд. Оставайтесь на странице.', 'kk': '10–30 секунд кетеді. Беттен шықпаңыз.', 'en': 'This usually takes 10–30 seconds. Stay on this page.'});
  static String get aiDiagnosis => _t({'ru': 'ИИ Диагноз', 'kk': 'ЖИ Диагнозы', 'en': 'AI Diagnosis'});
  static String get findings => _t({'ru': 'Находки', 'kk': 'Табылғандар', 'en': 'Findings'});
  static String get detectedAbnormalities => _t({'ru': 'Обнаруженные отклонения', 'kk': 'Анықталған ауытқулар', 'en': 'Detected Abnormalities'});
  static String get doctorValidation => _t({'ru': 'Заключение врача', 'kk': 'Дәрігер қорытындысы', 'en': 'Doctor Validation'});
  static String get validatedBy => _t({'ru': 'Проверено врачом', 'kk': 'Дәрігер тексерді', 'en': 'Validated by'});
  static String get doctorNotes => _t({'ru': 'Заметки врача', 'kk': 'Дәрігер жазбалары', 'en': 'Doctor Notes'});
  static String get awaitingReview => _t({'ru': 'Ожидает проверки врача', 'kk': 'Дәрігер тексеруін күтуде', 'en': 'Awaiting Doctor Review'});
  static String get awaitingReviewDesc => _t({'ru': 'Результат ИИ требует экспертной проверки.', 'kk': 'ЖИ нәтижесі сарапшы тексеруін қажет етеді.', 'en': 'The AI result requires expert validation before it is final.'});
  static String get analysisFailed => _t({'ru': 'Анализ не удался', 'kk': 'Талдау сәтсіз аяқталды', 'en': 'Analysis Failed'});
  static String get analysisFailedDesc => _t({'ru': 'ИИ не смог обработать изображение. Попробуйте загрузить снова.', 'kk': 'ЖИ суретті өңдей алмады. Қайта жүктеп көріңіз.', 'en': 'The AI could not process this image. Please try uploading again.'});
  static String get loadingAnalysis => _t({'ru': 'Загрузка анализа...', 'kk': 'Талдау жүктелуде...', 'en': 'Loading analysis...'});


  static String _t(Map<String, String> map) {
    return map[_locale.name] ?? map['en'] ?? '';
  }
}