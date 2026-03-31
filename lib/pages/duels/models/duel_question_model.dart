class DuelQuestionModel {
  final String question;
  final String type;

  const DuelQuestionModel({required this.question, required this.type});

  factory DuelQuestionModel.fromJson(Map<String, dynamic> json) {
    return DuelQuestionModel(question: json["question"], type: json["type"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "type": type
    };
  }
}