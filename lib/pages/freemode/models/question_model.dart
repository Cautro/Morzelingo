class QuestionModel {
  final String question;
  final String answer;

  QuestionModel({required this.question, required this.answer});

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(question: json["question"], answer: json["answer"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "answer": answer,
    };
  }
}