import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/herbs_data.dart';
import 'theme/app_colors.dart';
import 'navigation/app_navigator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Configure image cache for optimal memory and disk usage.
  // Herb images are typically small to medium resolution, so conservative limits.
  imageCache.maximumSize = 100; // max 100 images in memory
  imageCache.maximumSizeBytes = 100 * 1024 * 1024; // max 100 MB in memory

  // CachedNetworkImage disk cache is managed by DefaultCacheManager
  // Cache entries are kept for 30 days by default
  await dotenv.load(fileName: ".env");
  await HerbsData.initialize();
  runApp(const SieveApp());
}

class SieveApp extends StatelessWidget {
  const SieveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sieve Herbal Remedies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.card,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.foreground),
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const AppNavigator(),
    );
  }
}
