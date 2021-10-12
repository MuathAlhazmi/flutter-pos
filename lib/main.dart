import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_factory.dart';
import 'provider/src.dart';
import 'screens/edit_menu/main.dart';
import 'screens/expense_journal/main.dart';
import 'screens/history/main.dart';
import 'screens/lobby/main.dart';
import 'screens/menu/main.dart';
import 'screens/order_details/main.dart';
import 'storage_engines/connection_interface.dart';
import 'theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = DatabaseFactory().create('local-storage');

  runApp(PosApp(storage));
}

class PosApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) async {
    var state = context.findAncestorStateOfType<_PosAppState>();

    var prefs = await SharedPreferences.getInstance();

    await prefs.setString('languageCode', newLocale.languageCode);
    await prefs.setString('countryCode', "");

    state?.setState(() {
      state._locale = newLocale;
    });
  }

  final DatabaseConnectionInterface _storage;
  final Future _init;

  PosApp(this._storage) : _init = _storage.open();
  static _PosAppState? of(BuildContext context) => context.findAncestorStateOfType<_PosAppState>();

  @override
  State<PosApp> createState() => _PosAppState();
}

class _PosAppState extends State<PosApp> {
  Locale _locale = Locale('ar', 'ps');

  @override
  void initState() {
    super.initState();
    this._fetchLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
  }

  /*
  To get local from SharedPreferences if exists
   */
  Future<Locale> _fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();

    var languageCode = prefs.getString('languageCode') ?? 'ar';

    return Locale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('ar'), Locale('en')],
      initialRoute: '/',
      builder: (_, screen) => FutureBuilder<dynamic>(
        future: widget._init,
        builder: (_, dbSnapshot) {
          if (dbSnapshot.hasData) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => Supplier(database: widget._storage)),
                Provider(create: (_) => MenuSupplier(database: widget._storage)),
              ],
              child: screen,
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            );
          }
        },
      ),
      home: LobbyScreen(),
      onGenerateRoute: (settings) {
        final argMap = settings.arguments as Map?;
        final String heroTag = argMap != null ? argMap['heroTag'] ?? '' : '';

        switch (settings.name) {
          case '/menu':
            final TableModel model = argMap!['model'];
            return routeBuilder(MenuScreen(model, fromHeroTag: heroTag));
          case '/order-details':
            final TableModel order = argMap!['state'];
            final String fromScreen = argMap['from'] ?? '';

            return routeBuilder(
              DetailsScreen(
                order,
                fromHeroTag: heroTag,
                fromScreen: fromScreen,
              ),
            );
          case '/history':
            return routeBuilder(
              DefaultTabController(
                length: 2,
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (_) => HistorySupplierByDate(database: widget._storage),
                    ),
                    ChangeNotifierProxyProvider<HistorySupplierByDate, HistorySupplierByLine>(
                      create: (_) => HistorySupplierByLine(database: widget._storage),
                      update: (_, firstTab, lineChart) => lineChart!..update(firstTab),
                    ),
                  ],
                  child: HistoryScreen(),
                ),
              ),
            );
          case '/expense':
            return routeBuilder(
              ChangeNotifierProvider(
                create: (_) {
                  return ExpenseSupplier(database: widget._storage);
                },
                child: ExpenseJournalScreen(),
              ),
            );
          case '/edit-menu':
            return routeBuilder(EditMenuScreen());
          default:
            return MaterialPageRoute(builder: (context) => Center(child: Text('404')));
        }
      },
    );
  }
}

MaterialPageRoute routeBuilder(Widget screen) => MaterialPageRoute(
      builder: (_) => screen,
      maintainState: true,
    );

class FallbackCupertinoLocalisationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) => DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}
