//
//
// import 'dart:convert';
//
// import 'package:audioplayers/audioplayers.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../config.dart';
// import '../../../settings_context.dart';
// import '../../../storage_context.dart';
// import '../view/practice_audio_page.dart';
//
// class PracticeContext {
//
//
//
//   Future<Map> nextPracticeQuestion(data, index, isLast) async {
//       index++;
//       var question = data["questions"][index]["question"].toString().trim();
//       var answer = data["questions"][index]["answer"].toString().trim();
//       var type = data["questions"][index]["type"];
//       print('eeeeee$index, ${data["questions"].length}');
//       if (index >= data["questions"].length - 1) {
//         isLast = true;
//       } else {
//         isLast = false;
//       }
//       print(isLast);
//       if (isLast) {
//
//       } else {
//         question = data["questions"][index]["question"].toString().trim();
//         answer = data["questions"][index]["answer"].toString().trim();
//         type = data["questions"][index]["type"];
//       }
//
//       return {"question": question, "answer": answer, "type": type, "islast": isLast, "index": index};
//   }
//
//   void checkAnswer(String answer, String question) async {
//     final stats = PracticeContext().calculateStats(question, answer,);
//     await PracticeContext().sendStats(stats);
//   }
//
//   Future<Map> answerPracticeTextHandler(bool isLetter, String decoded, String answer) async {
//     String message;
//     bool success;
//     if (!isLetter) {
//       checkAnswer(answer, decoded);
//     }
//     if (decoded.trim() == answer) {
//       if (!isLetter) {
//         PracticeContext().practiceChecker(true);
//       }
//       message = "Верно!";
//       success = true;
//     } else {
//       if (isLetter) {
//         PracticeContext().practiceChecker(false);
//       }
//       message = "Неправильно";
//       success = false;
//     }
//     return {"message": message, "success": success};
//   }
//
//   Future<Map> answerPracticeMorseHandler(bool isLetter, String text, String answer) async {
//     String message;
//     bool success;
//     if (!isLetter) {
//       checkAnswer(answer, text);
//     }
//     if (text.trim().toUpperCase() == answer) {
//       if (!isLetter) {
//         PracticeContext().practiceChecker(true);
//       }
//       message = "Верно!";
//       success = true;
//     } else {
//       if (!isLetter) {
//         PracticeContext().practiceChecker(false);
//       }
//       message = "Неправильно";
//       success = false;
//     }
//     return {"success": success, "message": message};
//   }
//
//
//
//
//
//
// }