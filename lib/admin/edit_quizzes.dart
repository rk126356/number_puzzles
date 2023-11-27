import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:number_puzzles/models/number_puzzle_model.dart';

class EditQuizzes extends StatefulWidget {
  const EditQuizzes({Key? key}) : super(key: key);

  @override
  State<EditQuizzes> createState() => _EditQuizzesState();
}

class _EditQuizzesState extends State<EditQuizzes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Quizzes'),
      ),
      body: FutureBuilder(
        future: fetchQuizzes(),
        builder: (context, AsyncSnapshot<List<NumberPuzzle>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No quizzes available.');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Image.network(snapshot.data![index].questionImage),
                  subtitle: Text(snapshot.data!.length.toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteQuiz(snapshot.data![index].timestamp!);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<NumberPuzzle>> fetchQuizzes() async {
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

  void deleteQuiz(Timestamp timestamp) async {
    // Replace 'quizzes' with the actual collection name in Firestore

    final ref = await FirebaseFirestore.instance
        .collection('number_puzzles')
        .where('timestamp', isEqualTo: timestamp)
        .limit(1)
        .get();

    ref.docs.first.reference.delete();
    // ref.docs.first.reference.update({'isUnlocked': true});

    setState(() {});
  }
}
