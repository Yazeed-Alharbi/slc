class QuizQuestion {
  final String questionText;
  final List<QuizOption> options;
  final int correctOptionIndex;
  
  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
  
  // Factory constructor to create from JSON
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    List<QuizOption> options = (json['options'] as List)
        .map((option) => QuizOption.fromJson(option))
        .toList();
    
    return QuizQuestion(
      questionText: json['questionText'],
      options: options,
      correctOptionIndex: json['correctOptionIndex'],
    );
  }
}

class QuizOption {
  final String text;
  
  const QuizOption({required this.text});
  
  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(text: json['text']);
  }
}

class Quiz {
  final List<QuizQuestion> questions;
  
  const Quiz({required this.questions});
  
  factory Quiz.fromJson(Map<String, dynamic> json) {
    List<QuizQuestion> questions = (json['questions'] as List)
        .map((question) => QuizQuestion.fromJson(question))
        .toList();
    
    return Quiz(questions: questions);
  }
}