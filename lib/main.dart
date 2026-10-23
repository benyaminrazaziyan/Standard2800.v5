import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'state.dart';
import 'pages/input_page.dart';
import 'pages/floors_page.dart';
import 'pages/results_page.dart';

void main() => runApp(const SeismicApp());

class SeismicApp extends StatefulWidget {
  const SeismicApp({super.key});
  @override
  State<SeismicApp> createState() => _SeismicAppState();
}

class _SeismicAppState extends State<SeismicApp> {
  final AppState state = AppState();
  ThemeMode mode = ThemeMode.system;
  int tab = 0;

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: b,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          isDense: true,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'زلزله ۲۸۰۰ — ویرایش ۵',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: mode,
      home: Builder(builder: (context) {
        final pages = [
          InputPage(state: state, onGoResults: () => setState(() => tab = 2)),
          FloorsPage(state: state),
          ResultsPage(state: state),
        ];
        return Scaffold(
          appBar: AppBar(
            title: const Text('زلزله ۲۸۰۰ — ویرایش ۵'),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'تغییر پوسته',
                icon: Icon(mode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
                onPressed: () => setState(() => mode =
                    mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.tune), label: 'ورودی'),
              NavigationDestination(icon: Icon(Icons.apartment), label: 'طبقات'),
              NavigationDestination(icon: Icon(Icons.insights), label: 'نتایج'),
            ],
          ),
        );
      }),
    );
  }
}
