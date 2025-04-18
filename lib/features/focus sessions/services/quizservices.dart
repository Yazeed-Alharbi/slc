import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:slc/features/focus%20sessions/models/quizmodels.dart';
import 'package:slc/models/Material.dart';
import 'package:path/path.dart' as p;

class QuizService {
  static final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? "";
  static const String _baseUrl = "https://api.openai.com/v1";

  // Helper to download material file as bytes
  static Future<Uint8List> _downloadMaterialBytes(
      CourseMaterial material) async {
    final response = await http.get(Uri.parse(material.downloadUrl));
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to download ${material.name}: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  // Step 1: Upload file to OpenAI
  static Future<String> _uploadFile(
      String filename, Uint8List bytes, String purpose) async {
    final uri = Uri.parse("$_baseUrl/files");
    final request = http.MultipartRequest("POST", uri)
      ..headers["Authorization"] = "Bearer $_apiKey"
      // purpose *must* be "assistants" (plural) to support the Assistants API
      ..fields["purpose"] = purpose;

    // the field name *must* be "file"
    request.files.add(
      http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: filename,
        // optional: set a contentType if you want
        // contentType: MediaType("application", "octet-stream"),
      ),
    );

    final streamed = await request.send();
    final respBody = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception(
          "Error uploading file: ${streamed.statusCode} ‑ $respBody");
    }

    final data = jsonDecode(respBody) as Map<String, dynamic>;
    return data["id"] as String;
  }

  // Step 2: Create an assistant (vector_store attached via tool_resources)
  static Future<String> _createAssistant(String vectorStoreId) async {
    final payload = {
      "instructions":
          "You are an expert educator who creates multiple-choice quizzes. Based on the provided materials, generate a quiz with engaging, challenging questions. Each question should have exactly four plausible options and one correct answer.",
      "name": "Quiz Generator",
      "model": "gpt-4.1-nano-2025-04-14",
      "tools": [
        {"type": "file_search"}
      ],
      "tool_resources": {
        "file_search": {
          "vector_store_ids": [vectorStoreId]
        }
      }
    };

    final response = await http.post(
      Uri.parse("$_baseUrl/assistants"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
        "OpenAI-Beta": "assistants=v2",
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception("Error creating assistant: ${response.body}");
    }
    return jsonDecode(response.body)["id"];
  }

  // Step 3: Create a thread
  static Future<String> _createThread() async {
    final response = await http.post(
      Uri.parse("$_baseUrl/threads"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
        "OpenAI-Beta": "assistants=v2",
      },
      body: jsonEncode({}),
    );
    if (response.statusCode != 200) {
      throw Exception("Error creating thread: ${response.body}");
    }
    return jsonDecode(response.body)["id"];
  }

  // Step 4: Send the user’s quiz‐request as a message
  static Future<void> _addMessageToThread(
      String threadId, String content) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/threads/$threadId/messages"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
        "OpenAI-Beta": "assistants=v2",
      },
      body: jsonEncode({
        "role": "user",
        "content": content,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Error adding message: ${response.body}");
    }
  }

  // Step 5: Run the assistant on that thread
  static Future<String> _runAssistant(
      String threadId, String assistantId) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/threads/$threadId/runs"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
        "OpenAI-Beta": "assistants=v2",
      },
      body: jsonEncode({
        "assistant_id": assistantId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Error running assistant: ${response.body}");
    }
    return jsonDecode(response.body)["id"];
  }

  // Step 6: Poll for run completion
  static Future<void> _pollRunStatus(String threadId, String runId) async {
    bool isCompleted = false;

    while (!isCompleted) {
      final response = await http.get(
        Uri.parse('$_baseUrl/threads/$threadId/runs/$runId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'OpenAI-Beta': 'assistants=v2', // Add this header
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error checking run status: ${response.body}');
      }

      var data = jsonDecode(response.body);
      String status = data['status'];

      if (status == 'completed') {
        isCompleted = true;
      } else if (status == 'failed' || status == 'cancelled') {
        throw Exception('Run failed or was cancelled: $status');
      } else {
        // Wait before polling again
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  // Step 7: Get messages from thread
  static Future<String> _getMessages(String threadId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/threads/$threadId/messages'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'OpenAI-Beta': 'assistants=v2', // Add this header
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error getting messages: ${response.body}');
    }

    var data = jsonDecode(response.body);
    // Get the assistant's last message
    for (var message in data['data']) {
      if (message['role'] == 'assistant') {
        return message['content'][0]['text']['value'];
      }
    }

    throw Exception('No assistant response found');
  }

  static Future<String> _createVectorStore(List<String> fileIds) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/vector_stores"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
        "OpenAI-Beta": "assistants=v2",
      },
      body: jsonEncode({"file_ids": fileIds, "name": "Quiz Vector Store"}),
    );
    if (response.statusCode != 200) {
      throw Exception("Error creating vector store: ${response.body}");
    }
    return jsonDecode(response.body)["id"];
  }

  /// Extracts the first JSON object (from the first “{” to the last “}”)
  /// or throws if none found.
  static String _extractJsonObject(String s) {
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return s.substring(start, end + 1);
    }
    throw FormatException('No JSON object found in assistant response');
  }

  // Main method to generate quiz
  static Future<Quiz> getQuizForCourse(String courseId,
      [List<CourseMaterial>? materials]) async {
    if (materials == null || materials.isEmpty) {
      throw Exception(
          'No valid course materials were provided for quiz generation.');
    }

    // only support PDF, DOC/DOCX, PPT/PPTX
    final allowedExts = {'.pdf', '.doc', '.docx', '.ppt', '.pptx'};
    for (var mat in materials) {
      // parse URL, grab only the path component (no ?query)
      final uri = Uri.parse(mat.downloadUrl);
      final ext = p.extension(uri.path).toLowerCase();

      if (!allowedExts.contains(ext)) {
        throw Exception('Unsupported file type "$ext" for "${mat.name}". '
            'Only PDF, DOC/DOCX, PPT/PPTX supported.');
      }
      // …
    }

    try {
      print('Processing ${materials.length} materials for quiz generation...');

      // Step 1: Download and upload all materials
      List<String> fileIds = [];
      // …inside getQuizForCourse, in your upload loop…
      for (var material in materials) {
        print('Downloading and uploading ${material.name}...');
        final uri = Uri.parse(material.downloadUrl);
        final filename = p.basename(uri.path); // ← strip off ?query
        final fileId = await _uploadFile(
          filename,
          await _downloadMaterialBytes(material),
          "assistants",
        );
        fileIds.add(fileId);
      }

      // ...after uploading files...
      final vectorStoreId = await _createVectorStore(fileIds);
      final assistantId = await _createAssistant(vectorStoreId);
      // ...continue as before...

      // Step 3: Create thread
      print('Creating thread...');
      final threadId = await _createThread();

      // Step 4: Add message
      print('Adding message to thread...');
      await _addMessageToThread(
          threadId,
          'Create a comprehensive quiz that includes 10 multiple-choice questions. ' +
              'Ensure the quiz is challenging, avoiding overly straightforward questions. ' +
              'The questions should be based on the provided materials ONLY.' +
              'Each question should have exactly 4 options. ' +
              'Randomize the correct answers without following any predictable pattern. ' +
              'Makr sure that your response does not include and invalid characters that could potentially break the code' +
              'Return your response as a valid JSON object with this structure: ' +
              '{"questions": [{"questionText": "Question here", ' +
              '"options": [{"text": "Option 1"}, {"text": "Option 2"}, {"text": "Option 3"}, {"text": "Option 4"}], ' +
              '"correctOptionIndex": 0}]}');

      // Step 5: Run assistant
      print('Running assistant...');
      final runId = await _runAssistant(threadId, assistantId);

      // Step 6: Poll for completion
      print('Waiting for assistant to complete...');
      await _pollRunStatus(threadId, runId);

      // Step 7: Get messages
      print('Getting messages...');
      final response = await _getMessages(threadId);

      // DEBUG: print the raw assistant response
      print('Assistant raw response:\n$response');

      // 1) try to pull out the JSON object only
      String jsonStr;
      try {
        jsonStr = _extractJsonObject(response);
      } catch (e) {
        // fallback: preserve old code‐fence regex
        final m =
            RegExp(r'```json\s*(.*?)\s*```', dotAll: true).firstMatch(response);
        if (m != null) {
          jsonStr = m.group(1)!;
        } else {
          // last‐ditch: assume entire response is JSON
          jsonStr = response;
        }
      }

      print('Extracted JSON for quiz:\n$jsonStr');

      // 2) now safely decode
      final quizData = jsonDecode(jsonStr);
      return Quiz.fromJson(quizData);
    } catch (e) {
      rethrow;
    }
  }
}
