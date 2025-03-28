import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/focus%20sessions/models/quizmodels.dart';
import 'package:slc/features/focus%20sessions/screens/quiz_results.dart';
import 'package:slc/features/focus%20sessions/services/quizservices.dart';

import 'package:slc/features/focus%20sessions/widgets/quizchoices.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/Material.dart';

class QuizScreen extends StatefulWidget {
  final Course? course;
  final List<CourseMaterial> selectedMaterials;

  const QuizScreen({
    Key? key,
    this.course,
    this.selectedMaterials = const [],
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<Quiz> _quizFuture;
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  bool _isLoading = true;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    // Use course ID to fetch appropriate quiz
    String courseId = widget.course?.id ?? "default";

    // Pass the selected materials to the quiz service
    _quizFuture = QuizService.getQuizForCourse(
      courseId,
      widget.selectedMaterials, // Pass selected materials
    );

    _quizFuture.then((quiz) {
      setState(() {
        // Initialize user answers list with nulls (unanswered)
        _userAnswers = List.generate(quiz.questions.length, (_) => null);
        _isLoading = false;
      });
    });
  }

  void _handleAnswer(int answerIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion(Quiz quiz) {
    if (_currentQuestionIndex < quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _showResults = true;
      });
    }
  }

  int _calculateScore(Quiz quiz) {
    int correctAnswers = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (_userAnswers[i] == quiz.questions[i].correctOptionIndex) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;

    return WillPopScope(
      onWillPop: () async {
        // Prevent popping while loading
        return !_isLoading;
      },
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder<Quiz>(
            future: _quizFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  _isLoading) {
                return const Center(
                  child: SLCLoadingIndicator(
                    text: "Generating quiz",
                  ),
                );
              }

              if (snapshot.hasError) {
                // Instead of showing an error message,
                // pop the QuizScreen to return to the Focus Session context.
                Future.microtask(() {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error generating quiz. Please try again.',
                      ),
                    ),
                  );
                  Navigator.pop(context); // Pops the QuizScreen.
                });
                return Container(); // Return an empty container.
              }

              final quiz = snapshot.data!;

              if (_showResults) {
                return QuizResultsScreen(
                  quiz: quiz,
                  userAnswers: _userAnswers,
                );
              }

              final question = quiz.questions[_currentQuestionIndex];

              return SingleChildScrollView(
                child: Padding(
                  padding: SpacingStyles(context).defaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Question ${_currentQuestionIndex + 1}",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        "out of ${quiz.questions.length}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: screenHeight * 0.1),
                      Text(
                        question.questionText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.1),
                      QuizChoices(
                        key: ValueKey<int>(
                            _currentQuestionIndex), // add this key
                        initialSelectedIndex:
                            _userAnswers[_currentQuestionIndex],
                        choices: question.options
                            .map((option) => QuizChoice(
                                  text: option.text,
                                ))
                            .toList(),
                        onChoiceSelected: _handleAnswer,
                      ),
                      SizedBox(height: screenHeight * 0.1),
                      SLCButton(
                        onPressed: _userAnswers[_currentQuestionIndex] != null
                            ? () => _nextQuestion(quiz)
                            : null,
                        text: _currentQuestionIndex < quiz.questions.length - 1
                            ? "Next"
                            : "Finish",
                        backgroundColor: SLCColors.primaryColor,
                        foregroundColor: Colors.white,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
