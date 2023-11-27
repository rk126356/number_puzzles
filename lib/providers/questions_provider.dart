import 'package:flutter/cupertino.dart';
import 'package:number_puzzles/models/number_puzzle_model.dart';
import 'package:number_puzzles/pages/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

List<NumberPuzzle> providerGlobalQuestionsList = questionsList;

class QuestionsProvider extends ChangeNotifier {
  List<NumberPuzzle> _questionsList = [];

  QuestionsProvider() {
    _questionsList = [];
    // load questionsList from local storage on initialization
    _loadQuestionsList();
  }

  List<NumberPuzzle> get questionsList => _questionsList;

  void markQuestionCompleted(int index) {
    _questionsList[index].markCompleted();
    _saveQuestionsList(); // save questionsList to local storage
    notifyListeners();
  }

  void markQuestionUnlocked(int index) {
    _questionsList[index].markUnlocked();
    _saveQuestionsList(); // save questionsList to local storage
    notifyListeners();
  }

  void markQuestionIncomplete(int index) {
    _questionsList[index].markIncomplete();
    _saveQuestionsList(); // save questionsList to local storage
    notifyListeners();
  }

  // save questionsList to local storage
  void _saveQuestionsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedQuestions =
        _questionsList.map((q) => jsonEncode(q.toJson())).toList();
    await prefs.setStringList('questionsList', encodedQuestions);
  }

  // load questionsList from local storage
  void _loadQuestionsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedQuestions = prefs.getStringList('questionsList');
    if (encodedQuestions != null) {
      _questionsList = encodedQuestions
          .map((q) => NumberPuzzle.fromJson(json.decode(q)))
          .toList();
      notifyListeners();
    } else {
      _questionsList = providerGlobalQuestionsList;
      notifyListeners();
    }
    compareQuestions();
  }

  void compareQuestions() {
    if (_questionsList.length != providerGlobalQuestionsList.length) {
      for (var i = _questionsList.length;
          i < providerGlobalQuestionsList.length;
          i++) {
        _questionsList.add(providerGlobalQuestionsList[i]);
        _saveQuestionsList();
      }
    } else {
      for (var i = 0; i < providerGlobalQuestionsList.length; i++) {
        if (_questionsList[i].questionImage !=
            providerGlobalQuestionsList[i].questionImage) {
          if (_questionsList[i].isUnlocked!) {
            _questionsList[i] = providerGlobalQuestionsList[i];
            _questionsList[i].isUnlocked = true;
            _questionsList[i].isCompleted = false;
          } else {
            _questionsList[i] = providerGlobalQuestionsList[i];
            _saveQuestionsList();
          }
        }
      }
    }
    notifyListeners();
  }
}
