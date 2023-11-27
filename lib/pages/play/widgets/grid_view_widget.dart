import 'package:flutter/material.dart';
import 'package:number_puzzles/models/number_puzzle_model.dart';
import 'package:number_puzzles/pages/play/play_quiz_screen.dart';
import 'package:number_puzzles/widgets/hind_and_screen_widget.dart';

class LevelGridView extends StatefulWidget {
  final List<List<NumberPuzzle>> levels;
  const LevelGridView({super.key, required this.levels});

  @override
  // ignore: library_private_types_in_public_api
  _LevelGridViewState createState() => _LevelGridViewState();
}

class _LevelGridViewState extends State<LevelGridView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetIndex = widget.levels.indexWhere((level) =>
        level.every((question) => question.isUnlocked!) &&
        !level.every((question) => question.isCompleted!));
    // scroll to the target box if it exists
    if (targetIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          targetIndex * MediaQuery.of(context).size.height / 3000 * targetIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          3000 * 3000,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }

    return GridView.count(
      controller: _scrollController, //
      crossAxisCount: 4,
      padding: const EdgeInsets.all(16.0),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: List.generate(
        widget.levels.length,
        (index) {
          final level = index + 1; // get the level of the first question
          final isUnlocked =
              widget.levels[index].every((question) => question.isUnlocked!);
          final isCompleted =
              widget.levels[index].every((question) => question.isCompleted!);

          final question = widget.levels[index];

          return ScaleTransition(
            scale: _animation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  if (!isUnlocked) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return HintAnswerScreen(
                          onNext: () {
                            Navigator.pop(context);
                          },
                          explanation:
                              'This question is locked, please complete the previous question first!',
                          title: 'Question Locked!',
                          btnTitle: 'Got it!',
                        );
                      },
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlayQuizScreen(
                                question: question,
                                index: level - 1,
                                level: widget.levels,
                              )),
                    );
                  }
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        level.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isUnlocked && !isCompleted)
                        const Icon(Icons.play_arrow, color: Colors.orange),
                      if (!isUnlocked && !isCompleted)
                        const Icon(Icons.lock, color: Colors.black),
                      if (isCompleted && isUnlocked)
                        const Icon(Icons.check, color: Colors.green),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
