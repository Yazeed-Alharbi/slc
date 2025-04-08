import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:slc/features/focus%20sessions/models/quizmodels.dart';
import 'package:slc/models/Material.dart';

class QuizService {
  // OpenAI API endpoint
  static const String _openaiApiUrl = "https://api.openai.com/v1/responses";

  static final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? "";

  static Future<Quiz> getQuizForCourse(String courseId,
      [List<CourseMaterial>? materials]) async {
    if (materials != null && materials.isNotEmpty) {
      try {
        // Build content from materials
        final materialContents = materials.map((m) => m.name).join("\n\n");

        print('Material contents: $materialContents'); // Debug info

        // Create request to OpenAI API
        final response = await http.post(
          Uri.parse(_openaiApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            "model": "gpt-4o",
            "input": [
              {
                "role": "system",
                "content":
                    "You are an expert educator who creates multiple-choice quizzes. Based on the provided material, generate a quiz with engaging, challenging questions. Each question should have exactly four plausible options and one correct answer."
              },
              {
                "role": "user",
                "content":
                    "Create a comprehensive quiz that includes 10 multiple-choice questions. Ensure the quiz is challenging, avoiding overly straightforward questions. Randomize the correct answers without following any predictable pattern (i.e., correct answers should not predominantly fall under a specific letter). The quiz should be from the following material only, nothing else: $materialContents"
              }
            ],
            "text": {
              "format": {
                "type": "json_schema",
                "name": "quiz_generation",
                "schema": {
                  "type": "object",
                  "properties": {
                    "questions": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "questionText": {"type": "string"},
                          "options": {
                            "type": "array",
                            "items": {
                              "type": "object",
                              "properties": {
                                "text": {"type": "string"}
                              },
                              "required": ["text"],
                              "additionalProperties": false
                            }
                          },
                          "correctOptionIndex": {"type": "integer"}
                        },
                        "required": [
                          "questionText",
                          "options",
                          "correctOptionIndex"
                        ],
                        "additionalProperties": false
                      }
                    }
                  },
                  "required": ["questions"],
                  "additionalProperties": false
                },
                "strict": true
              }
            }
          }),
        );

        print('OpenAI API Response Status: ${response.statusCode}');
        print('OpenAI API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          // Extract output text from the nested structure
          final outputText = responseData['output'][0]['content'][0]['text'];
          print('Extracted output text: $outputText');

          // Parse the JSON string inside the text field
          final quizData = jsonDecode(outputText);

          // Now that we have the actual data, create the Quiz
          return Quiz.fromJson(quizData);
        } else {
          print('Error from OpenAI API: ${response.body}');
          throw Exception('Error generating quiz: ${response.body}');
        }
      } catch (e) {
        print('Error generating quiz: $e');
        print('Stack trace: ${StackTrace.current}');
        throw e; // Propagate error
      }
    }

    // Instead of falling back, throw an error when no valid materials.
    throw Exception(
        'No valid course materials were provided for quiz generation.');
  }
}
