class OpenQuestion {
  final String question;
  final String correctValue;
  String? userAnswer;

  OpenQuestion({
    required this.question,
    required this.correctValue,
    this.userAnswer,
  });

  factory OpenQuestion.fromJson(Map<String, dynamic> json) {
    return OpenQuestion(
      question: json['question'] as String,
      correctValue: json['correct_value'] as String,
    );
  }
}
