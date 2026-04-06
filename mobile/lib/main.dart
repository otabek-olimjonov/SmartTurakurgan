import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/utils/timeago_uz.dart';

import 'l10n/app_localizations.dart';
import 'core/config/app_config.dart';
import 'core/locale/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_notifier.dart';
import 'core/auth/secure_storage.dart';
import 'core/sync/sync_engine.dart';
import 'features/home/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/main_shell.dart';
import 'features/home/presentation/screens/splash_screen.dart';
import 'features/hokimiyat/presentation/screens/hokimiyat_screen.dart';
import 'features/tashkilotlar/presentation/screens/place_list_screen.dart';
import 'features/boglanish/presentation/screens/boglanish_screen.dart';
import 'features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'features/yangiliklar/presentation/screens/news_screen.dart';
import 'features/hokimiyat/presentation/screens/hokimiyat_about_screen.dart';
import 'features/hokimiyat/presentation/screens/tuman_about_screen.dart';
import 'features/home/presentation/screens/search_screen.dart';
import 'features/home/presentation/screens/notifications_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('uz', UzMessages());
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(ProviderScope(
    overrides: [
      dioProvider.overrideWith((ref) => buildDio(null)),
    ],
    child: const SmartTurakurganApp(),
  ));
}

Dio buildDio(String? jwt) {
  final dio = Dio(BaseOptions(
    baseUrl: '${AppConfig.supabaseUrl}/functions/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'apikey': AppConfig.supabaseAnonKey,
    },
  ));
  // Always inject the latest JWT from secure storage before every request.
  // This means even the singleton dioProvider (created with null jwt at startup)
  // will use the real user JWT after login is complete.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final storedJwt = await SecureStorage.getJwt();
      options.headers['Authorization'] =
          'Bearer ${storedJwt ?? AppConfig.supabaseAnonKey}';
      handler.next(options);
    },
  ));
  return dio;
}

class SmartTurakurganApp extends ConsumerWidget {
  const SmartTurakurganApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Smart Turakurgan',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uz'),
        Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
        Locale('ru'),
        Locale('en'),
      ],
      onGenerateRoute: _onGenerateRoute,
      home: const _AppRoot(),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/hokimiyat':
        return MaterialPageRoute(builder: (_) => const HokimiyatScreen());
      case '/turizm':
        return MaterialPageRoute(
          builder: (ctx) => PlaceListScreen(
            title: AppLocalizations.of(ctx).turizm,
            categories: const ['diqqat_joy', 'ovqatlanish', 'mexmonxona'],
          ),
        );
      case '/talim':
        return MaterialPageRoute(
          builder: (ctx) => PlaceListScreen(
            title: AppLocalizations.of(ctx).talim,
            categories: const [
              'oquv_markaz', 'maktabgacha', 'maktab', 'texnikum', 'oliy_talim'
            ],
          ),
        );
      case '/tibbiyot':
        return MaterialPageRoute(
          builder: (ctx) => PlaceListScreen(
            title: AppLocalizations.of(ctx).tibbiyot,
            categories: const ['davlat_tibbiyot', 'xususiy_tibbiyot'],
          ),
        );
      case '/tashkilotlar':
        return MaterialPageRoute(
          builder: (ctx) => PlaceListScreen(
            title: AppLocalizations.of(ctx).tashkilotlar,
            categories: const ['davlat_tashkilot', 'xususiy_korxona'],
          ),
        );
      case '/ai':
        return MaterialPageRoute(builder: (_) => const AiAssistantScreen());
      case '/boglanish':
        return MaterialPageRoute(builder: (_) => const BoglanishScreen());
      case '/news':
        return MaterialPageRoute(builder: (_) => const NewsScreen());
      case '/hokimiyat/about':
        return MaterialPageRoute(builder: (_) => const HokimiyatAboutScreen());
      case '/hokimiyat/tuman':
        return MaterialPageRoute(builder: (_) => const TumanAboutScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen(), fullscreenDialog: true);
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return null;
    }
  }
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    return authAsync.when(
      loading: () => const SplashScreen(),
      error: (_, __) => const LoginScreen(),
      data: (auth) {
        if (auth.status == AuthStatus.unauthenticated) return const LoginScreen();
        if (auth.isNewUser) return const OnboardingScreen();
        return _SyncBootstrap(child: const MainShell());
      },
    );
  }
}

class _SyncBootstrap extends ConsumerStatefulWidget {
  final Widget child;
  const _SyncBootstrap({required this.child});

  @override
  ConsumerState<_SyncBootstrap> createState() => _SyncBootstrapState();
}

class _SyncBootstrapState extends ConsumerState<_SyncBootstrap> {
  bool _synced = false;
  double _progress = 0.0;
  String _message = 'Ma\'lumotlar tekshirilmoqda...';

  @override
  void initState() {
    super.initState();
    _kickoffSync();
  }

  Future<void> _kickoffSync() async {
    final jwt = await SecureStorage.getJwt();
    final dio = buildDio(jwt);
    await SyncEngine(dio).runSync(
      onProgress: (progress, message) {
        if (mounted) setState(() { _progress = progress; _message = message; });
      },
    );
    if (mounted) setState(() => _synced = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_synced) {
      return SplashScreen(progress: _progress, message: _message);
    }
    return widget.child;
  }
}
