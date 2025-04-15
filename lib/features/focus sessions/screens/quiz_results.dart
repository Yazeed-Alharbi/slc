import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/features/focus%20sessions/models/quizmodels.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuizResultsScreen extends StatelessWidget {
  final Quiz quiz;
  final List<int?> userAnswers;

  const QuizResultsScreen({
    Key? key,
    required this.quiz,
    required this.userAnswers,
  }) : super(key: key);

  int _calculateScore() {
    int correctAnswers = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (userAnswers[i] == quiz.questions[i].correctOptionIndex) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();
    final percentage = (score / quiz.questions.length) * 100;
    final isGoodScore = percentage >= 70;
    final l10n = AppLocalizations.of(context);

    // Determine emoji based on score
    String emoji;
    if (percentage >= 90) {
      emoji = "🎉"; // Celebration
    } else if (percentage >= 70) {
      emoji = "👏"; // Applause
    } else if (percentage >= 50) {
      emoji = "🤔"; // Thinking
    } else {
      emoji = "📚"; // Books/Study
    }

    return Scaffold(
      body: SafeArea(
        // Make the entire screen scrollable
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header section with score
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isGoodScore
                      ? Colors.green.withOpacity(0.1)
                      : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.quizCompleted ?? "Quiz Completed!",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[300],
                            color: isGoodScore
                                ? SLCColors.green
                                : SLCColors.primaryColor,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "${percentage.toStringAsFixed(0)}%",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isGoodScore
                                        ? SLCColors.green
                                        : SLCColors.primaryColor,
                                  ),
                            ),
                            Text(
                              "$score/${quiz.questions.length}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isGoodScore
                          ? l10n?.greatJob ?? "Great job! You've mastered this material."
                          : l10n?.needToReview ?? "You need to review this material again.",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Questions review section - no longer in an Expanded widget
              // Using Column instead of ListView for questions
              Column(
                children: List.generate(
                  quiz.questions.length,
                  (index) {
                    final question = quiz.questions[index];
                    final userAnswerIndex = userAnswers[index];
                    final isCorrect =
                        userAnswerIndex == question.correctOptionIndex;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCorrect
                              ? SLCColors.green.withOpacity(0.5)
                              : Colors.amber.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? SLCColors.green.withOpacity(0.1)
                                        : Colors.amber.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      color: isCorrect
                                          ? SLCColors.green
                                          : Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    question.questionText,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color: isCorrect
                                      ? SLCColors.green
                                      : Colors.amber,
                                ),
                              ],
                            ),
                            const Divider(height: 24),

                            // User's answer
                            if (userAnswerIndex != null)
                              _buildAnswerTile(
                                context: context,
                                label: l10n?.yourAnswer ?? 'Your Answer:',
                                text: question.options[userAnswerIndex].text,
                                isCorrect: isCorrect,
                              ),

                            const SizedBox(height: 12),

                            // Correct answer (if user was wrong)
                            if (!isCorrect && userAnswerIndex != null)
                              _buildAnswerTile(
                                context: context,
                                label: l10n?.correctAnswer ?? 'Correct Answer:',
                                text: question
                                    .options[question.correctOptionIndex].text,
                                isCorrect: true,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Extra space before buttons
              const SizedBox(height: 24),

              // Bottom action buttons
              // Replace the SLCButton onPressed section with this:

// Bottom action buttons
              SizedBox(
                width: double.infinity,
                child: SLCButton(
                  onPressed: () {
                    // This will navigate back to the home screen, regardless of how user arrived
                    Navigator.of(context).popUntil((route) {
                      // Either pop until we reach the home route or until we reach the root
                      return route.isFirst;
                    });
                  },
                  text: l10n?.done ?? "Done",
                  backgroundColor: SLCColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerTile({
    required BuildContext context,
    required String label,
    required String text,
    required bool isCorrect,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect
                    ? SLCColors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isCorrect ? Colors.green[800] : Colors.red[800],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
