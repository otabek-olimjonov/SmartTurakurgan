-- 004_seed.sql — Demo content for Smart Turakurgan
-- Safe to run multiple times (uses INSERT ... ON CONFLICT DO NOTHING)

-- ─── Rahbariyat (Hokimiyat Leadership) ─────────────────────────────────────────
INSERT INTO rahbariyat (id, full_name, birth_year, position, category, phone, biography, reception_days, sort_order, is_published, translations)
VALUES
  (
    '11111111-0001-0001-0001-000000000001',
    'Ergashev Shuhrat Baxtiyor o''g''li',
    1978,
    'Turakurgan tumani hokimi',
    'hokim',
    '+998(69) 220-00-01',
    'Ergashev Shuhrat Baxtiyor o''g''li 1978-yilda Turakurgan tumanida tug''ilgan. Oliy ma''lumotli iqtisodchi. 2020-yildan buyon tuman hokimi lavozimida faoliyat yuritmoqda.',
    'Dushanba va Chorshanba: 9:00–12:00',
    1,
    true,
    '{"ru": {"full_name": "Эргашев Шухрат Бахтиёрович", "position": "Хоким Туракурганского района", "biography": "Родился в 1978 году. Экономист по образованию. С 2020 года работает хокимом района."}, "en": {"full_name": "Ergashev Shuhrat", "position": "Mayor of Turakurgan district", "biography": "Born in 1978. Economist by education. Serving as district mayor since 2020."}}'
  ),
  (
    '11111111-0001-0001-0001-000000000002',
    'Xoliqov Mansur Alijon o''g''li',
    1981,
    'Hokim birinchi o''rinbosari',
    'apparat',
    '+998(69) 220-00-02',
    'Xoliqov Mansur Alijon o''g''li 1981-yilda tug''ilgan. Huquqshunos. Hokimiyatda 10 yildan ortiq ish tajribasiga ega.',
    'Seshanba: 9:00–12:00',
    2,
    true,
    '{"ru": {"full_name": "Холиков Мансур Алижонович", "position": "Первый заместитель хокима"}}'
  ),
  (
    '11111111-0001-0001-0001-000000000003',
    'Rahimova Nilufar Baxtiyorovna',
    1985,
    'Moliya va iqtisodiyot bo''yicha hokim o''rinbosari',
    'apparat',
    '+998(69) 220-00-03',
    'Rahimova Nilufar Baxtiyorovna 1985-yilda tug''ilgan. Moliya va iqtisodiyot bo''yicha mutaxassis.',
    'Payshanba: 10:00–12:00',
    3,
    true,
    '{"ru": {"full_name": "Рахимова Нилуфар Бахтиёровна", "position": "Заместитель хокима по финансам и экономике"}}'
  ),
  (
    '11111111-0001-0001-0001-000000000004',
    'Yusupov Behruz Kamoliddin o''g''li',
    1980,
    'Ijtimoiy masalalar bo''yicha hokim o''rinbosari',
    'apparat',
    '+998(69) 220-00-04',
    'Yusupov Behruz Kamoliddin o''g''li 1980-yilda tug''ilgan. Ijtimoiy siyosat masalalari bo''yicha mutaxassis.',
    'Juma: 9:00–11:00',
    4,
    true,
    '{"ru": {"full_name": "Юсупов Бехруз Камолиддинович", "position": "Заместитель хокима по социальным вопросам"}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Mahallalar ─────────────────────────────────────────────────────────────────
INSERT INTO mahallalar (id, name, description, location_lat, location_lng, is_published, translations)
VALUES
  (
    '22222222-0001-0001-0001-000000000001',
    'Markaziy mahalla',
    'Turakurgan tumanining markaziy mahallasi. 2500 dan ortiq aholi yashaydi.',
    41.0012, 71.5645,
    true,
    '{"ru": {"name": "Центральная махалля", "description": "Центральная махалля Туракурганского района. Проживает более 2500 человек."}}'
  ),
  (
    '22222222-0001-0001-0001-000000000002',
    'Bog''iston mahalla',
    'Bog''iston mahallasi tuman janubi-g''arbiy qismida joylashgan. 1800 aholi.',
    40.9985, 71.5589,
    true,
    '{"ru": {"name": "Махалля Богистон", "description": "Расположена в юго-западной части района. 1800 жителей."}}'
  ),
  (
    '22222222-0001-0001-0001-000000000003',
    'Yangi hayot mahalla',
    'Yangi qurilish hududidagi zamonaviy mahalla. 3000 dan ziyod aholi.',
    41.0055, 71.5710,
    true,
    '{"ru": {"name": "Махалля Янги хаёт", "description": "Современная махалля в новом жилом районе. Более 3000 жителей."}}'
  ),
  (
    '22222222-0001-0001-0001-000000000004',
    'Navruz mahalla',
    'Tuman shimoliy qismida joylashgan. Asosan qishloq xo''jalik ishchilari yashaydi.',
    41.0089, 71.5598,
    true,
    '{"ru": {"name": "Махалля Навруз", "description": "Расположена в северной части района. Населена преимущественно сельскими жителями."}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Mahalla xodimlari ───────────────────────────────────────────────────────────
INSERT INTO mahalla_xodimlari (id, mahalla_id, full_name, position, phone, sort_order, translations)
VALUES
  (
    '33333333-0001-0001-0001-000000000001',
    '22222222-0001-0001-0001-000000000001',
    'Toshmatov Ulugbek Hamidovich',
    'Mahalla raisi',
    '+998(91) 234-56-78',
    1,
    '{"ru": {"full_name": "Тошматов Улугбек Хамидович", "position": "Председатель махалли"}}'
  ),
  (
    '33333333-0001-0001-0001-000000000002',
    '22222222-0001-0001-0001-000000000002',
    'Nazarova Mohira Xasanovna',
    'Mahalla raisi',
    '+998(93) 345-67-89',
    1,
    '{"ru": {"full_name": "Назарова Мохира Хасановна", "position": "Председатель махалли"}}'
  ),
  (
    '33333333-0001-0001-0001-000000000003',
    '22222222-0001-0001-0001-000000000003',
    'Qodirov Sanjar Rustamovich',
    'Mahalla raisi',
    '+998(90) 456-78-90',
    1,
    '{"ru": {"full_name": "Кодиров Санжар Рустамович", "position": "Председатель махалли"}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Yer maydonlari (E-auction land plots) ───────────────────────────────────────
INSERT INTO yer_maydonlari (id, title, area_hectares, location_lat, location_lng, status, auction_url, description, is_published, translations)
VALUES
  (
    '44444444-0001-0001-0001-000000000001',
    'Tijorat maqsadidagi yer maydon №1',
    0.25,
    41.0020, 71.5650,
    'active',
    'https://e-auksion.uz',
    'Turakurgan shaxar markazida joylashgan tijorat maqsadidagi yer maydon. Avtomobil yo''lining yonida qulay joylashuv.',
    true,
    '{"ru": {"title": "Земельный участок коммерческого назначения №1", "description": "Коммерческий земельный участок в центре города. Удобное расположение вдоль дороги."}}'
  ),
  (
    '44444444-0001-0001-0001-000000000002',
    'Turar-joy maqsadidagi yer maydon №2',
    0.10,
    40.9990, 71.5600,
    'active',
    'https://e-auksion.uz',
    'Turar-joy qurilishi uchun mo''ljallangan yer maydon. Barcha kommunikatsiyalar mavjud.',
    true,
    '{"ru": {"title": "Земельный участок жилого назначения №2", "description": "Земельный участок для жилого строительства. Имеются все коммуникации."}}'
  ),
  (
    '44444444-0001-0001-0001-000000000003',
    'Qishloq xo''jaligi uchun yer №3',
    5.00,
    41.0100, 71.5500,
    'active',
    'https://e-auksion.uz',
    'Qishloq xo''jaligi maqsadlarida foydalanish uchun yer maydon. Suv ta''minoti mavjud.',
    true,
    '{"ru": {"title": "Сельскохозяйственный земельный участок №3", "description": "Земельный участок для сельскохозяйственных целей. Имеется водоснабжение."}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Places: Tourism ─────────────────────────────────────────────────────────────
INSERT INTO places (id, category, name, director, phone, description, location_lat, location_lng, rating, is_published, translations)
VALUES
  -- Diqqatga sazovor joylar
  (
    '55555555-0001-0001-0001-000000000001',
    'diqqatga_sazovor_joylar',
    'Turakurgan qal''asi xarobalari',
    NULL,
    NULL,
    'Turakurgan qal''asining qadimiy xarobalari. Miloddan avvalgi II asrga oid tarixiy yodgorlik. Arxeologik qazishmalar davom etmoqda.',
    41.0025, 71.5580,
    4.5,
    true,
    '{"ru": {"name": "Руины крепости Туракурган", "description": "Древние руины крепости Туракурган. Исторический памятник II века до нашей эры. Продолжаются археологические раскопки."}, "en": {"name": "Turakurgan Fortress Ruins", "description": "Ancient ruins of Turakurgan fortress. Historical monument from 2nd century BC."}}'
  ),
  (
    '55555555-0001-0001-0001-000000000002',
    'diqqatga_sazovor_joylar',
    'Chust arxeologik yodgorligi',
    NULL,
    NULL,
    'Bronza davriga oid noyob arxeologik yodgorlik. O''zbek arxeologiyasida muhim o''rin tutadi.',
    40.9960, 71.5540,
    4.2,
    true,
    '{"ru": {"name": "Чустский археологический памятник", "description": "Уникальный памятник бронзового века. Занимает важное место в узбекской археологии."}}'
  ),
  -- Ovqatlanish
  (
    '55555555-0001-0001-0002-000000000001',
    'ovqatlanish',
    'Turakurgan choyxonasi',
    'Mamatov Jahongir',
    '+998(91) 123-45-67',
    'An''anaviy o''zbek taomlari. Somsa, lag''mon, shashlik. Keng maydonga ega. Bog'' bor.',
    41.0015, 71.5655,
    4.3,
    true,
    '{"ru": {"name": "Чайхана Туракурган", "director": "Маматов Жахонгир", "description": "Традиционная узбекская кухня. Самса, лагман, шашлык. Большая территория с садом."}}'
  ),
  (
    '55555555-0001-0001-0002-000000000002',
    'ovqatlanish',
    'Marvarid restoran',
    'Yusupova Gulnora',
    '+998(93) 234-56-78',
    'Zamonaviy va milliy taomlar. Toʻylar va tadbirlar uchun katta zal. 200 kishiga moʻljallangan.',
    41.0008, 71.5670,
    4.1,
    true,
    '{"ru": {"name": "Ресторан Марварид", "director": "Юсупова Гулнора", "description": "Современная и национальная кухня. Большой зал для свадеб и мероприятий на 200 человек."}}'
  ),
  -- Mexmonxonalar
  (
    '55555555-0001-0001-0003-000000000001',
    'mexmonxonalar',
    'Turakurgan mehmonxonasi',
    'Sharipov Baxtiyor',
    '+998(69) 220-11-22',
    '20 ta qulay xona. Konditsioner, Wi-Fi, nonushta kiradi. Markazda joylashgan.',
    41.0010, 71.5645,
    3.9,
    true,
    '{"ru": {"name": "Гостиница Туракурган", "director": "Шарипов Бахтиёр", "description": "20 комфортабельных номеров. Кондиционер, Wi-Fi, завтрак включён. Центральное расположение."}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Places: Education (ta'lim) ─────────────────────────────────────────────────
INSERT INTO places (id, category, name, director, phone, description, location_lat, location_lng, rating, is_published, translations)
VALUES
  (
    '66666666-0001-0001-0001-000000000001',
    'maktablar',
    '1-maktab (Turakurgan umumta''lim maktabi)',
    'Qosimova Zulfiya Hamidovna',
    '+998(69) 220-31-01',
    '1975-yilda tashkil etilgan. 1200 o''quvchi, 80 o''qituvchi. Chuqur o''rganish sinflari mavjud.',
    41.0005, 71.5640,
    4.4,
    true,
    '{"ru": {"name": "Школа №1 (Туракурган)", "director": "Косимова Зульфия Хамидовна", "description": "Основана в 1975 году. 1200 учеников, 80 учителей. Классы углублённого изучения предметов."}}'
  ),
  (
    '66666666-0001-0001-0001-000000000002',
    'maktablar',
    '5-maktab (Navruz mahalla maktabi)',
    'Tursunov Jasur Xurshidovich',
    '+998(69) 220-31-05',
    '1989-yilda qurilgan. Yangi sport zali. 900 o''quvchi.',
    41.0075, 71.5610,
    4.1,
    true,
    '{"ru": {"name": "Школа №5 (Махалля Навруз)", "director": "Турсунов Жасур Хуршидович", "description": "Построена в 1989 году. Новый спортзал. 900 учеников."}}'
  ),
  (
    '66666666-0002-0001-0001-000000000001',
    'maktabgacha',
    '3-MTM (Markaziy bog''cha)',
    'Nazarova Sabohat',
    '+998(69) 220-41-03',
    'Yoshi 3-6 yoshdagi bolalar uchun. 150 o''rin. Zamonaviy o''yin maydoni mavjud.',
    41.0018, 71.5648,
    4.6,
    true,
    '{"ru": {"name": "ДДУ №3 (Центральный)", "director": "Назарова Сабохат", "description": "Для детей 3-6 лет. 150 мест. Современная игровая площадка."}}'
  ),
  (
    '66666666-0003-0001-0001-000000000001',
    'texnikumlar',
    'Turakurgan agrar texnikumi',
    'Mirzayev Sohibjon Anvarovich',
    '+998(69) 220-51-01',
    'Qishloq xo''jaligi mutaxassisliklari: agronom, iqtisodchi, mexanizator. 600 talaba.',
    41.0030, 71.5590,
    4.0,
    true,
    '{"ru": {"name": "Туракурганский аграрный техникум", "director": "Мирзаев Сохибжон Анварович", "description": "Специальности сельского хозяйства: агроном, экономист, механизатор. 600 студентов."}}'
  ),
  (
    '66666666-0004-0001-0001-000000000001',
    'oquv_markazlari',
    'Bilim O''quv markazi',
    'Xasanova Dilnoza',
    '+998(90) 567-89-01',
    'Matematika, ingliz tili, IT kurslari. Maktab o''quvchilari va kattalar uchun.',
    41.0012, 71.5660,
    4.7,
    true,
    '{"ru": {"name": "Учебный центр Билим", "director": "Хасанова Дилноза", "description": "Математика, английский язык, IT курсы. Для школьников и взрослых."}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Places: Healthcare (tibbiyot) ───────────────────────────────────────────────
INSERT INTO places (id, category, name, director, phone, description, location_lat, location_lng, rating, is_published, translations)
VALUES
  (
    '77777777-0001-0001-0001-000000000001',
    'davlat_tibbiyot',
    'Turakurgan MChJ (Markaziy shifoxona)',
    'Dr. Abdullayev Hamid Yusufovich',
    '+998(69) 220-21-01',
    'Tuman markaziy shifoxonasi. 150 karavot. Barcha asosiy bo''limlar mavjud: jarrohlik, terapiya, ginekologiya, pediatriya.',
    41.0000, 71.5635,
    4.2,
    true,
    '{"ru": {"name": "Центральная больница Туракургана", "director": "Д-р Абдуллаев Хамид Юсуфович", "description": "Центральная районная больница. 150 коек. Все основные отделения: хирургия, терапия, гинекология, педиатрия."}}'
  ),
  (
    '77777777-0001-0001-0001-000000000002',
    'davlat_tibbiyot',
    'Navruz oilaviy poliklinikasi',
    'Dr. Karimova Nilufar',
    '+998(69) 220-22-02',
    'Oilaviy shifokorlar markazi. Profilaktika, emlaash, tibbiy ko''rik. Hafta kunlari 8:00-18:00.',
    41.0085, 71.5605,
    4.0,
    true,
    '{"ru": {"name": "Семейная поликлиника Навруз", "director": "Д-р Каримова Нилуфар", "description": "Центр семейных врачей. Профилактика, вакцинация, медосмотр. Пн-Пт 8:00-18:00."}}'
  ),
  (
    '77777777-0002-0001-0001-000000000001',
    'xususiy_tibbiyot',
    'MedPlus xususiy klinikasi',
    'Dr. Toshmatov Sarvar',
    '+998(91) 678-90-12',
    'Stomatologiya, ko''z shifokori, dermatolog. Zamonaviy uskunalar. Raqamli rentgen.',
    41.0022, 71.5665,
    4.5,
    true,
    '{"ru": {"name": "Частная клиника МедПлюс", "director": "Д-р Тошматов Сарвар", "description": "Стоматология, окулист, дерматолог. Современное оборудование. Цифровой рентген."}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Places: Tashkilotlar ─────────────────────────────────────────────────────────
INSERT INTO places (id, category, name, director, phone, description, location_lat, location_lng, is_published, translations)
VALUES
  (
    '88888888-0001-0001-0001-000000000001',
    'davlat_tashkilotlar',
    'Fuqarolik holati aktlarini qayd etish bo''limi (FHAQB)',
    'Mirzayeva Gulbahor',
    '+998(69) 220-61-01',
    'Tug''ilish, o''lim, nikoh, ajrashish guvohnomalari. Pasport xizmatlari. Ish vaqti: Dushanba-Juma 9:00-17:00.',
    41.0007, 71.5643,
    true,
    '{"ru": {"name": "ЗАГС (Отдел ЗАГС)", "director": "Мирзаева Гулбахор", "description": "Свидетельства о рождении, смерти, браке, разводе. Паспортные услуги. Пн-Пт 9:00-17:00."}}'
  ),
  (
    '88888888-0001-0001-0001-000000000002',
    'davlat_tashkilotlar',
    'Vergi inspeksiyasi',
    'Xolmatov Ravshan',
    '+998(69) 220-62-01',
    'Soliq to''lash, hisobotlar, litsenziyalar. Tadbirkorlar uchun maslahatlar.',
    41.0003, 71.5642,
    true,
    '{"ru": {"name": "Налоговая инспекция", "director": "Холматов Равшан", "description": "Уплата налогов, отчётность, лицензии. Консультации для предпринимателей."}}'
  ),
  (
    '88888888-0001-0001-0001-000000000003',
    'davlat_tashkilotlar',
    'Pensiya fondi bo''limi',
    'Usmonova Dildora',
    '+998(69) 220-63-01',
    'Nafaqa hisoblash, pensiya to''lashlar, nogironlik nafaqalari. Qabullar: Seshanba, Payshanba 9:00-12:00.',
    41.0001, 71.5638,
    true,
    '{"ru": {"name": "Пенсионный фонд (отдел)", "director": "Усмонова Дилдора", "description": "Начисление пенсий, пенсионные выплаты, пособия по инвалидности. Приём: Вт, Чт 9:00-12:00."}}'
  ),
  (
    '88888888-0002-0001-0001-000000000001',
    'xususiy_korxonalar',
    'Turakurgan go''sht kombinati',
    'Razzaqov Muzaffar',
    '+998(69) 220-71-01',
    'Mol go''shti va qo''y go''shti ishlab chiqarish. Ulgurji savdo. Mahalliy fermerlar bilan hamkorlik.',
    41.0050, 71.5520,
    true,
    '{"ru": {"name": "Туракурганский мясокомбинат", "director": "Раззаков Музаффар", "description": "Производство говядины и баранины. Оптовая торговля. Сотрудничество с местными фермерами."}}'
  ),
  (
    '88888888-0002-0001-0001-000000000002',
    'xususiy_korxonalar',
    'Farovon supermarket',
    'Tursunov Alisher',
    '+998(91) 789-01-23',
    'Oziq-ovqat mahsulotlari, maishiy texnika, kiyim-kechak. Shahar markazida.',
    41.0016, 71.5653,
    true,
    '{"ru": {"name": "Супермаркет Фаровон", "director": "Турсунов Алишер", "description": "Продукты питания, бытовая техника, одежда. В центре города."}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Yangiliklar (News) ───────────────────────────────────────────────────────────
INSERT INTO yangiliklar (id, title, body, category, is_published, published_at, translations)
VALUES
  (
    '99999999-0001-0001-0001-000000000001',
    'Turakurgan tumanida yangi maktab qurilishi boshlanadi',
    'Turakurgan tuman hokimligi 2025-yilda 600 o''rinli zamonaviy umumta''lim maktabi qurilishini boshlash haqida qaror qabul qildi. Maktab Yangi hayot mahallasida quriladi va 2026-yil sentyabrda o''quvchilarni qabul qilishga tayyorlanadi. Loyiha qiymati 12 milliard so''mni tashkil etadi.',
    'ta_lim',
    true,
    NOW() - INTERVAL '1 day',
    '{"ru": {"title": "В Туракургане начнётся строительство новой школы", "body": "Хокимият Туракурганского района принял решение о начале строительства современной общеобразовательной школы на 600 мест в 2025 году. Школа будет построена в махалле Янги хаёт и будет готова принять учеников в сентябре 2026 года. Стоимость проекта составляет 12 миллиардов сумов."}}'
  ),
  (
    '99999999-0001-0001-0001-000000000002',
    'Tuman markaziy shifoxonasiga yangi MRT apparati o''rnatildi',
    'Turakurgan tuman markaziy shifoxonasiga zamonaviy magnit-rezonans tomografiya (MRT) apparati o''rnatildi. Endi bemorlar tashxis uchun viloyat markaziga borishi shart emas. MRT tekshiruvi majburiy tibbiy sug''urta doirasida bepul amalga oshiriladi.',
    'tibbiyot',
    true,
    NOW() - INTERVAL '3 days',
    '{"ru": {"title": "В центральную больницу района установлен новый МРТ аппарат", "body": "В центральную больницу Туракурганского района установлен современный аппарат магнитно-резонансной томографии. Теперь пациентам не нужно ехать в областной центр. МРТ-исследование бесплатно в рамках обязательного медицинского страхования."}}'
  ),
  (
    '99999999-0001-0001-0001-000000000003',
    'Smart Turakurgan ilovasi ishga tushdi!',
    'Turakurgan tuman hokimligi barcha fuqarolar uchun mo''ljallangan "Smart Turakurgan" mobil ilovasi rasmiy ishga tushirilganligini e''lon qiladi. Ilovada tuman hokimligi, ta''lim, tibbiyot, turizm muassasalari va boshqa ko''plab xizmatlar haqida ma''lumotlar mavjud. Ilova App Store va Google Play do''konlarida bepul yuklab olinadi.',
    'texnologiya',
    true,
    NOW() - INTERVAL '5 days',
    '{"ru": {"title": "Приложение Smart Turakurgan запущено!", "body": "Хокимият Туракурганского района объявляет об официальном запуске мобильного приложения Smart Turakurgan для всех граждан. В приложении есть информация о хокимияте, учебных, медицинских, туристических учреждениях и многих других услугах. Приложение бесплатно скачивается в App Store и Google Play."}}'
  ),
  (
    '99999999-0001-0001-0001-000000000004',
    '2025-yil Navro''z bayrami tadbirlari e''lon qilindi',
    'Turakurgan tumanida 2025-yil 21-mart kuni Navro''z bayramini keng nishonlash rejalashtirilgan. Markaziy maydonda konsert, ko''rgazmalar, an''anaviy milliy o''yinlar, halim pishirish musobaqasi bo''lib o''tadi. Barcha fuqarolar tadbirga taklif etiladi.',
    'madaniyat',
    true,
    NOW() - INTERVAL '7 days',
    '{"ru": {"title": "Объявлена программа мероприятий Навруза 2025", "body": "В Туракурганском районе запланировано широкое празднование Навруза 21 марта 2025 года. На центральной площади состоятся концерт, выставки, традиционные игры, соревнование по приготовлению халима. Приглашаются все жители."}}'
  ),
  (
    '99999999-0001-0001-0001-000000000005',
    'Turakurganda elektr energiyasi tarmoqlari yangilandi',
    'Tuman hududida 15 km elektr uzatish liniyasi almashtirildi. Yangi transformator podstansiyalari o''rnatildi. Bu qayta tiklanadigan energiya manbalari loyihasi doirasida amalga oshirildi va elektr ta''minotini yaxshilaydi.',
    'infratuzilma',
    true,
    NOW() - INTERVAL '10 days',
    '{"ru": {"title": "В Туракургане обновлены электросети", "body": "На территории района заменено 15 км электропередающих линий. Установлены новые трансформаторные подстанции. Это сделано в рамках проекта возобновляемых источников энергии и улучшит электроснабжение."}}'
  )
ON CONFLICT (id) DO NOTHING;

-- ─── Bildirishnomalar (Notifications) ─────────────────────────────────────────────
INSERT INTO bildirishnomalar (id, title, body, target, is_sent, translations)
VALUES
  (
    'aaaaaaaa-0001-0001-0001-000000000001',
    'Smart Turakurgan ilovasiga xush kelibsiz!',
    'Ilovamizga xush kelibsiz. Bu yerda Turakurgan tumanining barcha xizmatlari haqida ma''lumot olishingiz mumkin.',
    'all',
    true,
    '{"ru": {"title": "Добро пожаловать в Smart Turakurgan!", "body": "Добро пожаловать в наше приложение. Здесь вы можете получить информацию обо всех услугах Туракурганского района."}}'
  )
ON CONFLICT (id) DO NOTHING;
