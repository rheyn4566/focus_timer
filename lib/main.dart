import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'providers/timer_provider.dart';
import 'providers/sound_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const FocusTimerApp());
}

class FocusTimerApp extends StatelessWidget {
  const FocusTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()),
      ],
      child: MaterialApp(
        title: 'Focus Timer & White Noise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFA500),
            secondary: Color(0xFFFFB733),
            surface: Color(0xFF1E1E1E),
            error: Color(0xFFCF6679),
            onPrimary: Color(0xFF121212),
            onSecondary: Color(0xFF121212),
            onSurface: Color(0xFFFFFFFF),
            onError: Color(0xFF000000),
          ),
          fontFamily: GoogleFonts.poppins().fontFamily,
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
