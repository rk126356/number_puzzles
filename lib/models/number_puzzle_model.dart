import 'package:cloud_firestore_platform_interface/src/timestamp.dart';

class NumberPuzzle {
  String questionImage;
  final String answer;
  bool isCompleted;
  bool isUnlocked;
  final String explanation;
  bool isAnswerShowed;
  Timestamp? timestamp;

  NumberPuzzle({
    required this.questionImage,
    required this.answer,
    required this.explanation,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.timestamp,
    this.isAnswerShowed = false,
  });

  void markCompleted() {
    isCompleted = true;
  }

  void markUnlocked() {
    isUnlocked = true;
  }

  void markIncomplete() {
    isCompleted = false;
  }

// Factory method to create a NumberPuzzle from a Map (usually from JSON)
  factory NumberPuzzle.fromJson(Map<String, dynamic> json) {
    return NumberPuzzle(
      questionImage: json['questionImage'],
      answer: json['answer'],
      explanation: json['explanation'],
      isCompleted: json['isCompleted'] ?? false,
      isUnlocked: json['isUnlocked'] ?? false,
      timestamp: json['timestamp'],
      isAnswerShowed: json['isAnswerShowed'] ?? false,
    );
  }

  // Method to convert the NumberPuzzle to a Map (usually for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'questionImage': questionImage,
      'answer': answer,
      'explanation': explanation,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
      'isAnswerShowed': isAnswerShowed,
    };
  }
}
