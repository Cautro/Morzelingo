class PracticeQuestionModel {
  final String question;
  final String answer;
  final String type;

  const PracticeQuestionModel({required this.question, required this.answer, required this.type});

  factory PracticeQuestionModel.fromJson(Map<String, dynamic> json) {
    return PracticeQuestionModel(question: json["question"], answer: json["answer"], type: json["type"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "answer": answer,
      "type": type,
    };
  }
}