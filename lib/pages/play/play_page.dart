import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:number_puzzles/models/number_puzzle_model.dart';
import 'package:number_puzzles/pages/play/widgets/grid_view_widget.dart';
import 'package:number_puzzles/providers/questions_provider.dart';
import 'package:number_puzzles/widgets/coin_icon_wdget.dart';
import 'package:number_puzzles/widgets/custom_app_bar_widget.dart';
import 'package:provider/provider.dart';

class PlayPageScreen extends StatefulWidget {
  const PlayPageScreen({super.key});

  @override
  State<PlayPageScreen> createState() => _PlayPageScreenState();
}

class _PlayPageScreenState extends State<PlayPageScreen> {
  List<List<NumberPuzzle>> levels = [];
  bool _isLoading = false;
  void fetchLevels() {
    setState(() {
      _isLoading = true;
    });
    final questionsProvider = Provider.of<QuestionsProvider>(context);
    levels =
        questionsProvider.questionsList.map((question) => [question]).toList();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // fetchLevels();
  }

  @override
  Widget build(BuildContext context) {
    final questionsProvider = Provider.of<QuestionsProvider>(context);
    List<List<NumberPuzzle>> levels =
        questionsProvider.questionsList.map((question) => [question]).toList();
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Center(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CoinIconWithText(),
          ))
        ],
        title: Text(
          'Play',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: _isLoading
          ? const CircularProgressIndicator()
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.black,
                  ],
                ),
              ),
              child: LevelGridView(levels: levels),
            ),
    );
  }
}
