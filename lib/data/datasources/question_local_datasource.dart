import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import '../models/question.dart';

/// Reads the raw question bank from the bundled JSON asset.
/// Kept separate from the repository so it can be swapped (e.g. for a
/// remote/API datasource later) without touching any ViewModel.
abstract class QuestionLocalDataSource {
  Future<List<Question>> loadStandardQuestions();
  Future<List<Question>> loadTrueFalseQuestions();
}

class QuestionLocalDataSourceImpl implements QuestionLocalDataSource {
  QuestionLocalDataSourceImpl({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static const _assetPath = 'assets/data/questions.json';

  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> _loadRaw() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(_assetPath);
    _cache = jsonDecode(raw) as Map<String, dynamic>;
    return _cache!;
  }

  @override
  Future<List<Question>> loadStandardQuestions() async {
    final data = await _loadRaw();
    final list = data['questions'] as List<dynamic>;
    return list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Question>> loadTrueFalseQuestions() async {
    final data = await _loadRaw();
    final list = data['trueFalseQuestions'] as List<dynamic>;
    return list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
