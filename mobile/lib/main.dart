import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/utils/timeago_uz.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_notifier.dart';
import 'core/auth/secure_storage.dart';
import 'core/sync/sync_engine.dart';
import 'features/home/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/main_shell.dart';
import 'features/hokimiyat/presentation/screens/hokimiyat_screen.dart';
import 'features/tashkilotlar/presentation/screens/place_list_screen.dart';
import 'features/boglanish/presentation/screens/boglanish_screen.dart';
import 'features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'features/yangiliklar/presentation/screens/news_screen.dart';

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
  return Dio(BaseOptions(
    baseUrl: '${AppConfig.supabaseUrl}/functions/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'apikey': AppConfig.supabaseAnonKey,
      'Authorization': 'Bearer ${jwt ?? AppConfig.supabaseAnonKey}',
    },
  ));
}

class SmartTurakurganApp extends ConsumerWidget {
  const SmartTurakurganApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Smart Turakurgan',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
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
          builder: (_) => const PlaceListScreen(
            title: 'Turizm',
            categories: ['diqqat_joy', 'ovqatlanish', 'mexmonxona'],
            tabLabels: ['Diqqatga sazovor', 'Ovqatlanish', 'Mehmonxonalar'],
          ),
        );
      case '/talim':
        return MaterialPageRoute(
          builder: (_) => const PlaceListScreen(
            title: 'Talim',
            categories: ['oquv_markaz', 'maktabgacha', 'maktab', 'texnikum', 'oliy_talim'],
            tabLabels: ['Oquv markazlari', 'Maktabgacha', 'Maktablar', 'Texnikumlar', 'Oliy talim'],
          ),
        );
      case '/tibbiyot':
        return MaterialPageRoute(
          builder: (_) => const PlaceListScreen(
            title: 'Tibbiyot',
            categories: ['davlat_tibbiyot', 'xususiy_tibbiyot'],
            tabLabels: ['Davlat tibbiyot', 'Xususiy klinikalar'],
          ),
        );
      case '/tashkilotlar':
        return MaterialPageRoute(
          builder: (_) => const PlaceListScreen(
            title: 'Tashkilotlar',
            categories: ['davlat_tashkilot', 'xususiy_korxona'],
            tabLabels: ['Davlat tashkilotlari', 'Xususiy korxonalar'],
          ),
        );
      case '/ai':
        return MaterialPageRoute(builder: (_) => const AiAssistantScreen());
      case '/boglanish':
        return MaterialPageRoute(builder: (_) => const BoglanishScreen());
      case '/news':
        return MaterialPageRoute(builder: (_) => const NewsScreen());
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
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
  bool _syncStarted = false;

  @override
  void initState() {
    super.initState();
    _kickoffSync();
  }

  Future<void> _kickoffSync() async {
    if (_syncStarted) return;
    _syncStarted = true;
    final jwt = await SecureStorage.getJwt();
    final dio = buildDio(jwt);
    SyncEngine(dio).runSync();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
