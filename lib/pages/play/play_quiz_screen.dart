import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:number_puzzles/models/number_puzzle_model.dart';
import 'package:number_puzzles/pages/home/home_page.dart';
import 'package:number_puzzles/pages/play/play_page.dart';
import 'package:number_puzzles/pages/shop/shop_page.dart';
import 'package:number_puzzles/providers/coin_provider.dart';
import 'package:number_puzzles/providers/questions_provider.dart';
import 'package:number_puzzles/providers/sound_provider.dart';
import 'package:number_puzzles/widgets/coin_icon_wdget.dart';
import 'package:number_puzzles/widgets/correct_ans_widget.dart';
import 'package:number_puzzles/widgets/hind_and_screen_widget.dart';
import 'package:provider/provider.dart';

class PlayQuizScreen extends StatefulWidget {
  final List<NumberPuzzle> question;
  final int index;
  final List<List<NumberPuzzle>> level;
  const PlayQuizScreen(
      {Key? key,
      required this.question,
      required this.index,
      required this.level})
      : super(key: key);

  @override
  State<PlayQuizScreen> createState() => _PlayQuizScreenState();
}

class _PlayQuizScreenState extends State<PlayQuizScreen> {
  String typedAns = '';
  bool wrongAnswer = false;

  @override
  void initState() {
    super.initState();
    final music = Provider.of<AudioProvider>(context, listen: false);
    if (music.isMusicTurnedOn) {
      music.quizMusicPlayingTrue();
      music.stopMusic();
      music.playQuizMusic();
    }
  }

  @override
  void dispose() {
    super.dispose();
    final music = Provider.of<AudioProvider>(context, listen: false);
    if (music.isMusicTurnedOn) {
      music.quizMusicPlayingFalse();
      music.stopQuizMusic();
      music.playMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (value) {
        final music = Provider.of<AudioProvider>(context, listen: false);
        if (music.isMusicTurnedOn) {
          music.quizMusicPlayingFalse();
          music.stopQuizMusic();
          music.playMusic();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          actions: const [
            Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CoinIconWithText(),
            ))
          ],
          title: Text(
            'Level: ${widget.index + 1}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF1F1F1F),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF121212), Color(0xFF1F1F1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image
                  Image.network(
                    widget.question[0].questionImage,
                    height: 250,
                  ),
                  const SizedBox(height: 20),
                  // Input field for user's answer
                  TextFormField(
                    controller: TextEditingController(text: typedAns),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          wrongAnswer ? 'Wrong Answer' : 'Enter your answer',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          wrongAnswer ? Colors.red : const Color(0xFF292929),
                    ),
                  ),
                  if (wrongAnswer)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Wrong Answer",
                        style: GoogleFonts.macondoSwashCaps(
                            color: Colors.red, fontSize: 22),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Numeric keypad
                  Column(
                    children: [
                      // Rows of the keypad
                      for (int i = 0; i < 3; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int j = 1; j <= 3; j++)
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child:
                                    buildNumberButton((i * 3 + j).toString()),
                              ),
                          ],
                        ),
                      // Last row of the keypad
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: buildBackspaceButton(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: buildNumberButton('0'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: buildSubmitButton(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: handleShowAnswer,
                    child: Container(
                      width: 210,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white60,
                            width: 2), // Set your border color and width
                        borderRadius: BorderRadius.circular(12),
                        color: Colors
                            .transparent, // Set the background color of the border
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Show Answer',
                              style: GoogleFonts.nabla().copyWith(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/coin_icon.png', // Replace with the path to your coin icon image
                              height: 30,
                              width: 30,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.question[0].isAnswerShowed ? '0' : '-50',
                              style: GoogleFonts.nabla().copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNumberButton(String number) {
    final music = Provider.of<AudioProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () {
        if (music.isSoundTurnedOn) {
          music.tap();
        }
        setState(() {
          typedAns += number;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          number,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget buildBackspaceButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (typedAns.isNotEmpty) {
            typedAns = typedAns.substring(0, typedAns.length - 1);
          }
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[800],
        shape: const CircleBorder(),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Icon(Icons.backspace),
      ),
    );
  }

  Widget buildSubmitButton() {
    final questionsProvider =
        Provider.of<QuestionsProvider>(context, listen: false);
    final music = Provider.of<AudioProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () {
        if (widget.question[0].answer == typedAns.toString()) {
          if (music.isSoundTurnedOn) {
            music.win();
          }
          questionsProvider.markQuestionCompleted(widget.index);
          questionsProvider.markQuestionUnlocked(widget.index + 1);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PlayQuizScreen(
                      question: widget.level[widget.index + 1],
                      index: widget.index + 1,
                      level: widget.level,
                    )),
          );
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CorrectAnswerScreen(
                  explanation: widget.question[0].explanation,
                  image: widget.question[0].questionImage,
                  onNext: () {
                    Navigator.pop(
                      context,
                    );
                  },
                );
              });
        } else {
          if (music.isSoundTurnedOn) {
            music.wrong();
          }
          setState(() {
            wrongAnswer = true;
          });
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              wrongAnswer = false;
            });
          });
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF00B0FF),
        shape: const CircleBorder(),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Icon(Icons.check),
      ),
    );
  }

  void handleShowAnswer() {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final music = Provider.of<AudioProvider>(context, listen: false);
    if (coinProvider.coins >= 30) {
      if (music.isSoundTurnedOn) {
        music.ans();
      }
      if (!widget.question[0].isAnswerShowed) {
        coinProvider.subtractCoins(50);
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return HintAnswerScreen(
            btnTitle: "Thanks!",
            explanation: widget.question[0].answer,
            title: "Answer",
            onNext: () {
              Navigator.pop(context);
            },
          );
        },
      );
      setState(() {
        widget.question[0].isAnswerShowed = true;
      });
    } else {
      if (music.isSoundTurnedOn) {
        music.wrong();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return HintAnswerScreen(
            btnTitle: "Okay!",
            explanation: 'You don\'t have enough coins.',
            title: "Low Coins!",
            doubleButtonTitle: "Get More Coins >",
            onNext: () {
              Navigator.pop(context);
            },
            onNextDoubleButton: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ShopPageScreen(),
                ),
              );
            },
          );
        },
      );
    }
  }
}
