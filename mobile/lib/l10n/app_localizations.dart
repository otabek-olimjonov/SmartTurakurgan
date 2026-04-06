import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ru'),
    Locale('uz'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl')
  ];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'Smart Turakurgan'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In uz, this message translates to:
  /// **'Barcha xizmatlar — bitta ilovada'**
  String get appSlogan;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In uz, this message translates to:
  /// **'Xarita'**
  String get navMap;

  /// No description provided for @navNews.
  ///
  /// In uz, this message translates to:
  /// **'Yangiliklar'**
  String get navNews;

  /// No description provided for @navProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @hokimiyat.
  ///
  /// In uz, this message translates to:
  /// **'Tuman hokimligi'**
  String get hokimiyat;

  /// No description provided for @turizm.
  ///
  /// In uz, this message translates to:
  /// **'Turizm'**
  String get turizm;

  /// No description provided for @talim.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'lim'**
  String get talim;

  /// No description provided for @tibbiyot.
  ///
  /// In uz, this message translates to:
  /// **'Tibbiyot'**
  String get tibbiyot;

  /// No description provided for @tashkilotlar.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotlar'**
  String get tashkilotlar;

  /// No description provided for @aiAssistant.
  ///
  /// In uz, this message translates to:
  /// **'AI Yordamchi'**
  String get aiAssistant;

  /// No description provided for @boglanish.
  ///
  /// In uz, this message translates to:
  /// **'Bog\'lanish'**
  String get boglanish;

  /// No description provided for @loginTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali kirish'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali kirish'**
  String get loginButton;

  /// No description provided for @loginWaiting.
  ///
  /// In uz, this message translates to:
  /// **'Telegram botda tasdiqlang...'**
  String get loginWaiting;

  /// No description provided for @onboardingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlaringizni kiriting'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xizmatlardan to\'liq foydalanish uchun quyidagi ma\'lumotlarni kiriting.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get onboardingSkip;

  /// No description provided for @onboardingTelegramDone.
  ///
  /// In uz, this message translates to:
  /// **'Ismingiz va telefon raqamingiz Telegram orqali saqlandi.'**
  String get onboardingTelegramDone;

  /// No description provided for @fullName.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ism'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In uz, this message translates to:
  /// **'Manzil'**
  String get address;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @loading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinib ko\'ring'**
  String get retry;

  /// No description provided for @empty.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot topilmadi'**
  String get empty;

  /// No description provided for @search.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get search;

  /// No description provided for @details.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get details;

  /// No description provided for @call.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq'**
  String get call;

  /// No description provided for @directions.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalish'**
  String get directions;

  /// No description provided for @rahbariyat.
  ///
  /// In uz, this message translates to:
  /// **'Rahbariyat'**
  String get rahbariyat;

  /// No description provided for @mahallalar.
  ///
  /// In uz, this message translates to:
  /// **'Mahallalar'**
  String get mahallalar;

  /// No description provided for @murojaatTitle.
  ///
  /// In uz, this message translates to:
  /// **'Murojaat yuborish'**
  String get murojaatTitle;

  /// No description provided for @murojaatMessage.
  ///
  /// In uz, this message translates to:
  /// **'Murojaat matni'**
  String get murojaatMessage;

  /// No description provided for @murojaatSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get murojaatSubmit;

  /// No description provided for @murojaatSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Murojaatingiz qabul qilindi!'**
  String get murojaatSuccess;

  /// No description provided for @aiQuick1.
  ///
  /// In uz, this message translates to:
  /// **'Subsidiya olish tartibi'**
  String get aiQuick1;

  /// No description provided for @aiQuick2.
  ///
  /// In uz, this message translates to:
  /// **'Yer olish tartibi'**
  String get aiQuick2;

  /// No description provided for @aiQuick3.
  ///
  /// In uz, this message translates to:
  /// **'Nafaqa masalalari'**
  String get aiQuick3;

  /// No description provided for @aiHint.
  ///
  /// In uz, this message translates to:
  /// **'Savol bering...'**
  String get aiHint;

  /// No description provided for @hokimiyatAbout.
  ///
  /// In uz, this message translates to:
  /// **'Hokimiyat to\'g\'risida'**
  String get hokimiyatAbout;

  /// No description provided for @apparat.
  ///
  /// In uz, this message translates to:
  /// **'Apparat'**
  String get apparat;

  /// No description provided for @kengash.
  ///
  /// In uz, this message translates to:
  /// **'Kengash'**
  String get kengash;

  /// No description provided for @yerMaydon.
  ///
  /// In uz, this message translates to:
  /// **'Yer maydonlari'**
  String get yerMaydon;

  /// No description provided for @workers.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get workers;

  /// No description provided for @statusActive.
  ///
  /// In uz, this message translates to:
  /// **'Aktiv'**
  String get statusActive;

  /// No description provided for @statusSold.
  ///
  /// In uz, this message translates to:
  /// **'Sotilgan'**
  String get statusSold;

  /// No description provided for @statusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get statusPending;

  /// No description provided for @directorLabel.
  ///
  /// In uz, this message translates to:
  /// **'Rahbar'**
  String get directorLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get descriptionLabel;

  /// No description provided for @locationLabel.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv'**
  String get locationLabel;

  /// No description provided for @mapLabel.
  ///
  /// In uz, this message translates to:
  /// **'Xarita'**
  String get mapLabel;

  /// No description provided for @mapLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Xarita yuklanmadi'**
  String get mapLoadError;

  /// No description provided for @appAbout.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get appAbout;

  /// No description provided for @languageSetting.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get languageSetting;

  /// No description provided for @logout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get editProfile;

  /// No description provided for @notLoggedIn.
  ///
  /// In uz, this message translates to:
  /// **'Kirish amalga oshirilmagan'**
  String get notLoggedIn;

  /// No description provided for @selectLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get selectLanguage;

  /// No description provided for @services.
  ///
  /// In uz, this message translates to:
  /// **'Xizmatlar'**
  String get services;

  /// No description provided for @eAuction.
  ///
  /// In uz, this message translates to:
  /// **'E-auksion'**
  String get eAuction;

  /// No description provided for @hectares.
  ///
  /// In uz, this message translates to:
  /// **'gektar'**
  String get hectares;

  /// No description provided for @allCategories.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi'**
  String get allCategories;

  /// No description provided for @categorySchools.
  ///
  /// In uz, this message translates to:
  /// **'Maktablar'**
  String get categorySchools;

  /// No description provided for @categoryPreschools.
  ///
  /// In uz, this message translates to:
  /// **'MTM'**
  String get categoryPreschools;

  /// No description provided for @categoryStateHospitals.
  ///
  /// In uz, this message translates to:
  /// **'Shifoxona'**
  String get categoryStateHospitals;

  /// No description provided for @categoryPrivateClinics.
  ///
  /// In uz, this message translates to:
  /// **'Klinika'**
  String get categoryPrivateClinics;

  /// No description provided for @categoryRestaurants.
  ///
  /// In uz, this message translates to:
  /// **'Restoran'**
  String get categoryRestaurants;

  /// No description provided for @categoryHotels.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxona'**
  String get categoryHotels;

  /// No description provided for @categoryAttractions.
  ///
  /// In uz, this message translates to:
  /// **'Attraksion'**
  String get categoryAttractions;

  /// No description provided for @errorGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik'**
  String get errorGeneric;

  /// No description provided for @reviews.
  ///
  /// In uz, this message translates to:
  /// **'izoh'**
  String get reviews;

  /// No description provided for @neighborhoodsNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mahallalar topilmadi'**
  String get neighborhoodsNotFound;

  /// No description provided for @landPlotsNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Yer maydonlari topilmadi'**
  String get landPlotsNotFound;

  /// No description provided for @errorOccurred.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi. Qayta urinib ko\'ring.'**
  String get errorOccurred;

  /// No description provided for @biography.
  ///
  /// In uz, this message translates to:
  /// **'Tarjimai hol'**
  String get biography;

  /// No description provided for @kontaktlar.
  ///
  /// In uz, this message translates to:
  /// **'Kontaktlar'**
  String get kontaktlar;

  /// No description provided for @murojaat.
  ///
  /// In uz, this message translates to:
  /// **'Murojaat'**
  String get murojaat;

  /// No description provided for @murojaatRateLimit.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik limit (5) oshib ketdi'**
  String get murojaatRateLimit;

  /// No description provided for @murojaatConnectingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada siz bilan bog\'lanamiz.'**
  String get murojaatConnectingSoon;

  /// No description provided for @newMurojaat.
  ///
  /// In uz, this message translates to:
  /// **'Yangi murojaat'**
  String get newMurojaat;

  /// No description provided for @telegramChannel.
  ///
  /// In uz, this message translates to:
  /// **'Telegram kanalimiz'**
  String get telegramChannel;

  /// No description provided for @receptionOffice.
  ///
  /// In uz, this message translates to:
  /// **'Qabul xonasi'**
  String get receptionOffice;

  /// No description provided for @duty.
  ///
  /// In uz, this message translates to:
  /// **'Navbatchi'**
  String get duty;

  /// No description provided for @emailLabel.
  ///
  /// In uz, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @workHours.
  ///
  /// In uz, this message translates to:
  /// **'Ish vaqti: Dush–Juma 09:00–18:00'**
  String get workHours;

  /// No description provided for @enterName.
  ///
  /// In uz, this message translates to:
  /// **'Ismni kiriting'**
  String get enterName;

  /// No description provided for @enterPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon kiriting'**
  String get enterPhone;

  /// No description provided for @enterAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni kiriting'**
  String get enterAddress;

  /// No description provided for @enterMessage.
  ///
  /// In uz, this message translates to:
  /// **'Murojaat matnini kiriting'**
  String get enterMessage;

  /// No description provided for @minChars.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 10 belgi kiriting'**
  String get minChars;

  /// No description provided for @tabAttractions.
  ///
  /// In uz, this message translates to:
  /// **'Diqqatga sazovor'**
  String get tabAttractions;

  /// No description provided for @tabRestaurants.
  ///
  /// In uz, this message translates to:
  /// **'Ovqatlanish'**
  String get tabRestaurants;

  /// No description provided for @tabHotels.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxonalar'**
  String get tabHotels;

  /// No description provided for @tabLearningCenters.
  ///
  /// In uz, this message translates to:
  /// **'O\'quv markazlari'**
  String get tabLearningCenters;

  /// No description provided for @tabPreschools.
  ///
  /// In uz, this message translates to:
  /// **'Maktabgacha'**
  String get tabPreschools;

  /// No description provided for @tabSchools.
  ///
  /// In uz, this message translates to:
  /// **'Maktablar'**
  String get tabSchools;

  /// No description provided for @tabColleges.
  ///
  /// In uz, this message translates to:
  /// **'Texnikumlar'**
  String get tabColleges;

  /// No description provided for @tabUniversities.
  ///
  /// In uz, this message translates to:
  /// **'Oliy ta\'lim'**
  String get tabUniversities;

  /// No description provided for @tabStateHospitals.
  ///
  /// In uz, this message translates to:
  /// **'Davlat tibbiyoti'**
  String get tabStateHospitals;

  /// No description provided for @tabPrivateClinics.
  ///
  /// In uz, this message translates to:
  /// **'Xususiy klinikalar'**
  String get tabPrivateClinics;

  /// No description provided for @tabStateOrgs.
  ///
  /// In uz, this message translates to:
  /// **'Davlat tashkilotlari'**
  String get tabStateOrgs;

  /// No description provided for @tabPrivateEnterprises.
  ///
  /// In uz, this message translates to:
  /// **'Xususiy korxonalar'**
  String get tabPrivateEnterprises;

  /// No description provided for @hokimiyatOrgName.
  ///
  /// In uz, this message translates to:
  /// **'Turakurgan tuman hokimligi'**
  String get hokimiyatOrgName;

  /// No description provided for @hokimiyatRegion.
  ///
  /// In uz, this message translates to:
  /// **'Namangan viloyati'**
  String get hokimiyatRegion;

  /// No description provided for @addressValue.
  ///
  /// In uz, this message translates to:
  /// **'Namangan viloyati, Turakurgan tumani,\nMustaqillik ko\'chasi 1'**
  String get addressValue;

  /// No description provided for @workHoursValue.
  ///
  /// In uz, this message translates to:
  /// **'Dushanba – Juma\n09:00 – 18:00 (tushlik: 13:00–14:00)'**
  String get workHoursValue;

  /// No description provided for @tumanAbout.
  ///
  /// In uz, this message translates to:
  /// **'Tuman to\'g\'risida'**
  String get tumanAbout;

  /// No description provided for @tumanKeyFacts.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy ma\'lumotlar'**
  String get tumanKeyFacts;

  /// No description provided for @tumanAreaLabel.
  ///
  /// In uz, this message translates to:
  /// **'Maydon'**
  String get tumanAreaLabel;

  /// No description provided for @tumanPopulationLabel.
  ///
  /// In uz, this message translates to:
  /// **'Aholi'**
  String get tumanPopulationLabel;

  /// No description provided for @tumanFoundedLabel.
  ///
  /// In uz, this message translates to:
  /// **'Asos solingan'**
  String get tumanFoundedLabel;

  /// No description provided for @tumanMahallalarLabel.
  ///
  /// In uz, this message translates to:
  /// **'Mahallalar'**
  String get tumanMahallalarLabel;

  /// No description provided for @tumanGeographyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Geografik o\'rni'**
  String get tumanGeographyTitle;

  /// No description provided for @tumanGeographyBody.
  ///
  /// In uz, this message translates to:
  /// **'Turakurgan tumani Namangan viloyatining shimoli-sharqida joylashgan. Shimoldan Pap tumani, janubdan Yangiqo\'rg\'on va Uychi tumanlari, g\'arbdan Namangan shahri bilan chegaradosh.\n\nTumanningmarkazi Turakurgan shaharchasi bo\'lib, u viloyat markazidan 35 km masofada joylashgan. Hudud tekislik va tog\' oldi zonalarini o\'z ichiga oladi.'**
  String get tumanGeographyBody;

  /// No description provided for @tumanEconomyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Iqtisodiyot'**
  String get tumanEconomyTitle;

  /// No description provided for @tumanEconomyBody.
  ///
  /// In uz, this message translates to:
  /// **'Tuman iqtisodiyotining asosini qishloq xo\'jaligi tashkil etadi: paxta, g\'alla, meva va sabzavotchilik rivojlangan. To\'qimachilik sanoati ham muhim o\'rin egallaydi.\n\nAholi farovonligini oshirish maqsadida kichik va o\'rta biznesni qo\'llab-quvvatlash, ishtiyoqmand tadbirkorlar uchun qulay shart-sharoitlar yaratish bo\'yicha faol ishlar olib borilmoqda.'**
  String get tumanEconomyBody;

  /// No description provided for @districtAboutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tuman to\'g\'risida'**
  String get districtAboutTitle;

  /// No description provided for @districtAboutBody.
  ///
  /// In uz, this message translates to:
  /// **'Turakurgan tumani — O\'zbekistonning Namangan viloyatidagi eng yirik tumanlardan biri. Tuman 1926-yilda tashkil etilgan bo\'lib, markazi Turakurgan shaharchasi hisoblanadi.\n\nTuman hududi 1 095 km² ni tashkil etib, aholisi 200 mingdan ortiq kishini tashkil etadi. Iqtisodiyot asosini qishloq xo\'jaligi, to\'qimachilik va oziq-ovqat sanoati tashkil etadi.\n\nTurakurgan tumani Namangan viloyatining shimoli-sharqida joylashgan bo\'lib, shimoldan Pap tumani, janubdan Yangiqo\'rg\'on va Uychi tumanlari bilan chegaradosh.'**
  String get districtAboutBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'uz':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppLocalizationsUzCyrl();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
