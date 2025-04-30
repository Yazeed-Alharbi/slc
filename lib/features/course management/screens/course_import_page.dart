import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/repositories/course_repository.dart';

class CourseImportPage extends StatefulWidget {
  const CourseImportPage({Key? key}) : super(key: key);

  @override
  State<CourseImportPage> createState() => _CourseImportPageState();
}

class _CourseImportPageState extends State<CourseImportPage> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );

  bool _isVerifying = false;
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndImport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _codeController.text.trim().toUpperCase();
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // First find the course ID from the share code
      final foundId = await _courseRepository.findCourseByShareCode(code);

      if (foundId == null) {
        setState(() {
          _isVerifying = false;
          _errorMessage =
              l10n?.courseNotFound ?? "No course found with this code";
        });

        // Show error in flushbar
        SLCFlushbar.show(
          context: context,
          message: l10n?.courseNotFound ?? "No course found with this code",
          type: FlushbarType.error,
        );
        return;
      }

      // Check if the user already has this course
      final alreadyHasCourse = await _courseRepository.userHasCourse(foundId);
      if (alreadyHasCourse) {
        setState(() {
          _isVerifying = false;
          _errorMessage = l10n?.courseAlreadyImported ??
              "You already have this course in your library";
        });

        // Show duplicate course error
        SLCFlushbar.show(
          context: context,
          message: l10n?.courseAlreadyImported ??
              "You already have this course in your library",
          type: FlushbarType.error,
        );
        return;
      }

      setState(() {
        _isVerifying = false;
        _isImporting = true;
      });

      await _courseRepository.cloneCourse(foundId);

      // Return result to previous screen
      Navigator.of(context).pop('imported');
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _isImporting = false;
        _errorMessage = e.toString();
      });

      // Show error flushbar
      SLCFlushbar.show(
        context: context,
        message: e.toString(),
        type: FlushbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n?.importCourse ?? "Import Course",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isVerifying && !_isImporting) ...[
                Text(
                  l10n?.enterShareCodePrompt ??
                      "Enter a 6-character share code to import a course",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                SLCTextField(
                  labelText: l10n?.shareCode ?? "Share Code",
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n?.shareCodeRequired ??
                          "Share code is required";
                    }
                    if (value.length != 6) {
                      return l10n?.shareCodeLength ??
                          "Share code must be 6 characters";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                SLCButton(
                  onPressed: _verifyAndImport,
                  text: l10n?.verify ?? "Verify",
                  backgroundColor: SLCColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ],
              if (_isVerifying) ...[
                SizedBox(height: 40),
                Center(
                    child: SLCLoadingIndicator(
                  text: l10n?.verifyingCode ?? "Verifying code...",
                )),
              ],
              if (_isImporting) ...[
                SizedBox(height: 40),
                Center(
                    child: SLCLoadingIndicator(
                  text: l10n?.importingCourse ?? "Importing course...",
                )),
                SizedBox(height: 16),
                Center(
                  
                  child: Text(
                    l10n?.importingCourseExplanation ??
                        "This may take a moment if the course has many materials.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
