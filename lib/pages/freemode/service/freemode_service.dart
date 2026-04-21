
class FreemodeService {

  bool answerHandler(String text, String answer) {
    if (text.toUpperCase().trim() == answer.toUpperCase().trim()) {
      return true;
    } else {
      return false;
    }
  }
}