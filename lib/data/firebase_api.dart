import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:number_puzzles/models/number_puzzle_model.dart';

class FetchQuestions {
  static Future<List<NumberPuzzle>> fetchQuestions() async {
    List<NumberPuzzle> questions = [];

    // Check if questions are available in local storage
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cachedQuestions = prefs.getString('cached_questions') ?? '';

    final data = await FirebaseFirestore.instance
        .collection('appInfo')
        .doc('t24RkgPVXADO1i9wu3YJ')
        .get();

    final info = data.data();

    final questionNumber = info?['questionNumber'];

    if (cachedQuestions.isNotEmpty) {
      if (kDebugMode) {
        print("Fetching questions from local storage");
      }

      // Decode the JSON string and add questions to the list
      questions = (json.decode(cachedQuestions) as List)
          .map((data) => NumberPuzzle.fromJson(data))
          .toList();

      if (questionNumber != questions.length) {
        // Fetch questions from Firebase
        questions = await fetchQuestionsFromFirebase();

        // Cache questions in local storage
        prefs.setString('cached_questions', json.encode(questions));
      }
    } else {
      // Fetch questions from Firebase
      questions = await fetchQuestionsFromFirebase();

      // Cache questions in local storage
      prefs.setString('cached_questions', json.encode(questions));
    }
    return questions;
  }

  static Future<List<NumberPuzzle>> fetchQuestionsFromFirebase() async {
    List<NumberPuzzle> questions = [];

    if (kDebugMode) {
      print('Fetching questions from Firebase');
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference collection =
        firestore.collection('number_puzzles');

    QuerySnapshot querySnapshot = await collection.orderBy('timestamp').get();
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (QueryDocumentSnapshot document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      NumberPuzzle question = NumberPuzzle.fromJson(data);
      questions.add(question);
    }

    return questions;
  }
}
