import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CorrectAnswerScreen extends StatefulWidget {
  final VoidCallback onNext;
  final String explanation;
  final String image;

  const CorrectAnswerScreen({
    Key? key,
    required this.onNext,
    required this.explanation,
    required this.image,
  }) : super(key: key);

  @override
  _CorrectAnswerScreenState createState() => _CorrectAnswerScreenState();
}

class _CorrectAnswerScreenState extends State<CorrectAnswerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ConfettiController _confettiController = ConfettiController();
  bool showExplanation = true; // Toggle variable

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _confettiController.play();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.05,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                  ],
                ),
              ),
              const Text(
                'Correct!',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: 2,
                    color: Colors.blue,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showExplanation = true;
                            });
                          },
                          child: Text(
                            showExplanation ? "Explanation" : "Question Image",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    showExplanation
                        ? Text(
                            widget.explanation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          )
                        : Image.network(widget.image),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showExplanation
                              ? showExplanation = false
                              : showExplanation = true;
                        });
                      },
                      child: Text(
                        showExplanation
                            ? "Show Question Image"
                            : "Show Explanation",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Next Question >',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
