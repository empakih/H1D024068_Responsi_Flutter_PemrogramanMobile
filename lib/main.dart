import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherViewModel()..init()),
        ChangeNotifierProvider(create: (_) => LocationViewModel()..init()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeViewModel>().themeMode;
          return MaterialApp(
            title: 'Weather App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
