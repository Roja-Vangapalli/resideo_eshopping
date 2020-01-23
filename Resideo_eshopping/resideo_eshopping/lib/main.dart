import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resideo_eshopping/Screens/home_page.dart';
import 'package:resideo_eshopping/model/user_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:resideo_eshopping/controller/app_localizations.dart';
import 'package:catcher/catcher_plugin.dart';
void main()  => runApp(MyApp());
// {
//
//  CatcherOptions debugOptions =
//  CatcherOptions(DialogReportMode(), [ConsoleHandler()]);
//  CatcherOptions releaseOptions = CatcherOptions(SilentReportMode(), [
//    EmailManualHandler(["eshopping_poc@grr.la"])
//  ]);
//
//  Catcher(MyApp(), debugConfig: debugOptions, releaseConfig: releaseOptions);
//}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(builder: (context) => UserRepository.instance(),) ],
      child: MaterialApp(
//        navigatorKey: Catcher.navigatorKey,
      title: 'Resideo e-Shopping',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: [
        const Locale('en','US'),
        const Locale('sk','SK'),
      ],
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      home: HomePage(),
    ),
    );
  }
}