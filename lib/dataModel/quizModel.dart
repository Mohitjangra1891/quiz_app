class Quiz {
  final int id;
  final String title;
  final String description;

  final double negativeMarks;
  final double correctAnswerMarks;
  final int questionsCount;

  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questionsCount,

    required this.negativeMarks,
    required this.correctAnswerMarks,

    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,

      negativeMarks: double.tryParse(json['negative_marks'] ?? '1.0') ?? 1.0,  // Safely parse as double
      correctAnswerMarks: double.tryParse(json['correct_answer_marks'] ?? '4.0') ?? 4.0, // Safely parse as double
      questionsCount: json['questions_count'],

      questions: List<Question>.from(
        (json['questions'] as List).map((x) => Question.fromJson(x as Map<String, dynamic>)),
      ),
    );
  }
}

class Question {
  final int id;
  final String description;

  final List<Option> options;
  String? selectedAnswer;


  Question({
    required this.id,
    required this.description,
    this.selectedAnswer,

    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      description: json['description'] as String,

      options: List<Option>.from(
        (json['options'] as List).map((x) => Option.fromJson(x as Map<String, dynamic>)),
      ),
    );
  }
}

class Option {
  final int id;
  final String description;
  final int questionId;
  final bool isCorrect;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool unanswered;
  final dynamic photoUrl;

  Option({
    required this.id,
    required this.description,
    required this.questionId,
    required this.isCorrect,
    required this.createdAt,
    required this.updatedAt,
    required this.unanswered,
    this.photoUrl,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as int,
      description: json['description'] as String,
      questionId: json['question_id'] as int,
      isCorrect: json['is_correct'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      unanswered: json['unanswered'] as bool,
      photoUrl: json['photo_url'],
    );
  }
}
