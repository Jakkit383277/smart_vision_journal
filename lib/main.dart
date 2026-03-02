import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/theme_service.dart';
import 'features/journal/presentation/bloc/note_bloc.dart';
import 'features/journal/presentation/bloc/note_event.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env not loaded: $e');
  }

  await Hive.initFlutter();
  await Hive.openBox('notes_cache');
  await Hive.openBox('settings');

  await di.init();

  final themeService = ThemeService();
  await themeService.init();

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return AnimatedBuilder(
      animation: themeService,
      builder: (context, _) {
        return BlocProvider<NoteBloc>(
          create: (_) => di.sl<NoteBloc>()..add(const LoadNotes()),
          child: ThemeServiceProvider(
            themeService: themeService,
            child: MaterialApp.router(
              title: 'Smart Vision Journal',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeService.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              routerConfig: appRouter.config(),
              debugShowCheckedModeBanner: false,
            ),
          ),
        );
      },
    );
  }
}