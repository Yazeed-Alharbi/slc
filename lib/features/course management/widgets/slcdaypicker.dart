import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'slcdaypickeritem.dart';

class SLCDayPicker extends StatefulWidget {
  final Function(List<String>) onSelectionChanged;
  final List<String> initialSelection;

  SLCDayPicker({
    Key? key,
    required this.onSelectionChanged,
    this.initialSelection = const [],
  }) : super(key: key);

  @override
  _SLCDayPickerState createState() => _SLCDayPickerState();
}

class _SLCDayPickerState extends State<SLCDayPicker> {
  late List<String> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = List<String>.from(widget.initialSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelectionChanged(selectedDays);
    });
  }

  void toggleSelection(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
      widget.onSelectionChanged(selectedDays);
    });
  }

  // Get localized day names based on current locale
  List<String> getDayLabels(BuildContext context) {
    // Check if we're in Arabic locale
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      // Full Arabic day names
      return ["أحد", "اثنين", "ثلاثاء", "أربعاء", "خميس", "جمعة", "سبت"];
    } else {
      // English abbreviated day names
      return ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    }
  }

  // Get standardized day codes regardless of display language
  List<String> getDayCodes() {
    return ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = getDayLabels(context);
    final dayCodes = getDayCodes();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: List.generate(7, (index) {
          final dayCode = dayCodes[index];
          final dayLabel = dayLabels[index];

          return SLCDayPickerItem(
            dayLabel: dayLabel,
            isSelected: selectedDays.contains(dayCode),
            onTap: () => toggleSelection(dayCode),
          );
        }),
      ),
    );
  }
}
