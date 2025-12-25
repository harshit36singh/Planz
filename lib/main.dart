import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planz/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';

Future<void> main() async{
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp();
await Hive.initFlutter();

await Hive.openBox("todo");
  runApp(
    ProviderScope(
   child:  MyApp()),);
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.jostTextTheme()
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Approuter.landing,
      onGenerateRoute: Approuter.generateRoute,

    );
  }
}
