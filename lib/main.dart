import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/audio_handler.dart';
import 'providers/player_provider.dart';
import 'providers/library_provider.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;
  late final StorageService storageService;
  late final MyAudioHandler audioHandler;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      storageService = StorageService();
      await storageService.init();

      audioHandler = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.rushe.channel.audio',
          androidNotificationChannelName: 'Rush Music Playback',
          androidNotificationOngoing: true,
        ),
      );

      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e, st) {
      debugPrint('Initialization error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          backgroundColor: Color(0xFF0F0C16),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider(audioHandler)),
        ChangeNotifierProvider(create: (_) => LibraryProvider(storageService)),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          return library.userProfile == null
              ? const OnboardingScreen()
              : const MainScreen();
        },
      ),
    );
  }
}
