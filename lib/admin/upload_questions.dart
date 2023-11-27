import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:number_puzzles/models/number_puzzle_model.dart';

class UploadQuiestions extends StatefulWidget {
  const UploadQuiestions({Key? key}) : super(key: key);

  @override
  State<UploadQuiestions> createState() => _UploadQuiestionsState();
}

class _UploadQuiestionsState extends State<UploadQuiestions> {
// Function to upload questions to Firebase Firestore
  static Future<void> uploadQuestionsToFirebase(
      List<NumberPuzzle> questions) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference collection =
        firestore.collection('number_puzzles');

    for (NumberPuzzle question in questions) {
      // Upload the image to Firebase Storage
      String imageUrl = await uploadImageToStorage(question.questionImage);

      // Update the question with the Firebase Storage URL
      question.questionImage = imageUrl;

      // Add the question to Firestore
      await collection.add(question.toJson());
    }
  }

  // Function to upload an image to Firebase Storage
  static Future<String> uploadImageToStorage(String imageUrl) async {
    final Dio dio = Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
    final Response<Uint8List> response = await dio.get<Uint8List>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final Uint8List imageData = response.data!;
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

    await ref.putData(imageData);

    // Get the download URL of the uploaded image
    return await ref.getDownloadURL();
  }

  List<NumberPuzzle> questions = [
    NumberPuzzle(
      questionImage:
          'https://www.indiabix.com/_files/images/puzzles/10-20-q-26.png',
      answer: '9',
      explanation:
          'In each triangle, multiply the lower two numbers together and add the upper number to give the value in the centre.',
      isUnlocked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // await uploadQuestionsToFirebase(questions);
          },
          child: Text('Add Questions to Firestore'),
        ),
      ),
    );
  }
}
