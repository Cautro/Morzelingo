import '../services/practice_service.dart';

abstract class IPracticeRepository {
  Future<void> completeLesson(String id);
  Future<List> getPracticeQuestion(String id);
  Future<void> sendStats(List<SymbolUpdate> updates);
  Future<List> getLetterQuestion();
}