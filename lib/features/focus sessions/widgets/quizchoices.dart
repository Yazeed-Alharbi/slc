import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';

class QuizChoices extends StatefulWidget {
  final List<QuizChoice> choices;
  final Function(int) onChoiceSelected;
  final int? initialSelectedIndex;

  const QuizChoices({
    Key? key,
    required this.choices,
    required this.onChoiceSelected,
    this.initialSelectedIndex,
  }) : super(key: key);

  @override
  State<QuizChoices> createState() => _QuizChoicesState();
}

class _QuizChoicesState extends State<QuizChoices> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.choices.length,
        (index) {
          final choice = widget.choices[index];
          final isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onChoiceSelected(index);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                overlayColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: isSelected
                    ? SLCColors.primaryColor
                    : Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(255, 76, 76, 76)
                        : Colors.white,
                backgroundColor: Theme.of(context).colorScheme.surfaceTint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isSelected
                      ? BorderSide(color: SLCColors.primaryColor)
                      : BorderSide.none,
                ),
              ),
              child: Text(
                choice.text,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuizChoice {
  final String text;

  final TextAlign textAlign;

  const QuizChoice({
    required this.text,
    this.textAlign = TextAlign.start,
  });
}
