import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

import '../dataModel/quizModel.dart';

final quizProvider = FutureProvider<Quiz>((ref) async {
  const String apiUrl = 'https://api.jsonserve.com/Uw5CrX';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Parse the response body into a Quiz object
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Quiz.fromJson(jsonData);
    } else {
      throw Exception('Failed to load quiz');
    }
  } catch (e) {
    throw Exception('Failed to load quiz: $e');
  }
});

class QuizNotifier extends StateNotifier<List<Question>> {
  QuizNotifier(List<Question> initialQuestions) : super(initialQuestions);

  void selectAnswer(int questionIndex, String selectedAnswer) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == questionIndex)
          state[i].copyWith(selectedAnswer: selectedAnswer)
        else
          state[i],
    ];
  }
}

extension QuestionCopyWith on Question {
  Question copyWith({String? selectedAnswer}) {
    return Question(
      id: id,
      description: description,
      options: options,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
    );
  }
}

final userAnswersProvider =
StateNotifierProvider<QuizNotifier, List<Question>>((ref) {
  final quiz = ref.watch(quizProvider).asData?.value;
  return QuizNotifier(quiz?.questions ?? []);
});
