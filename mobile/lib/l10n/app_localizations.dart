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
