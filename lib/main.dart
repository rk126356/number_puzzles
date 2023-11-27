import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:number_puzzles/pages/home/home_page.dart';
import 'package:number_puzzles/providers/coin_provider.dart';
import 'package:number_puzzles/providers/purchase_value_provider.dart';
import 'package:number_puzzles/providers/questions_provider.dart';
import 'package:number_puzzles/providers/sound_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoinProvider()),
        ChangeNotifierProvider(create: (_) => QuestionsProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseValueProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(useMaterial3: false),
        debugShowCheckedModeBanner: false,
        home: const HomePageScreen());
  }
}
