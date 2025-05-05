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
  static String? _cachedVectorStoreId;
  static String? _cachedAssistantId;

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

  // Step 2: Create assistant properly with file search capability
  static Future<String> _createAssistant(String vectorStoreId) async {
    final quizSchema = {
      "type": "object",
      "properties": {
        "questions": {
          "type": "array",
          "minItems": 10,
          "maxItems": 10,
          "items": {
            "type": "object",
            "properties": {
              "questionText": {
                "type": "string",
                "description": "The text of the question"
              },
              "options": {
                "type": "array",
                "minItems": 4,
                "maxItems": 4,
                "items": {
                  "type": "object",
                  "properties": {
                    "text": {"type": "string"}
                  },
                  "required": ["text"]
                }
              },
              "correctOptionIndex": {"type": "integer"}
            },
            "required": ["questionText", "options", "correctOptionIndex"]
          }
        }
      },
      "required": ["questions"]
    };

    final payload = {
      "instructions":
          "You are an expert educator who creates multiple-choice quizzes EXCLUSIVELY from provided materials. "
              "CRITICAL: You MUST follow this EXACT process:\n"
              "1. Begin by using the file_search tool to search for key terms and read the content\n"
              "2. Include DIRECT QUOTES from materials in your questions\n"
              "3. Generate EXACTLY 10 questions, each with 4 options\n"
              "4. ONLY use facts and information that appear in the materials\n"
              "5. If materials have limited content, reuse concepts to create all 10 questions\n"
              "6. Each question must reference specific content from materials\n"
              "IMPORTANT: If you cannot access files, explain the error clearly",
      "name": "Quiz Generator",
      "model": "gpt-4.1-nano-2025-04-14",
      "tools": [
        {"type": "file_search"}
      ],
      "tool_resources": {
        "file_search": {
          "vector_store_ids": [
            vectorStoreId
          ] // Connect to the vector store with materials
        }
      },
      "response_format": {
        "type": "json_schema",
        "json_schema": {"name": "quiz_schema", "schema": quizSchema}
      }
    };

    // Rest of your method remains the same
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
        'OpenAI-Beta': 'assistants=v2',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error getting messages: ${response.body}');
    }

    var data = jsonDecode(response.body);
    print("Raw response: ${response.body.substring(0, 500)}...");

    // Get the assistant's last message
    for (var message in data['data']) {
      if (message['role'] == 'assistant') {
        // For structured responses
        if (message['content'][0]['type'] == 'text') {
          final content = message['content'][0]['text']['value'];
          print("Found assistant message: $content");
          return content;
        }
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
      final fileIds = await Future.wait(materials.map((mat) async {
        final uri = Uri.parse(mat.downloadUrl);
        final filename = p.basename(uri.path);
        final bytes = await _downloadMaterialBytes(mat);
        print(
            "Preparing to upload ${mat.name}, file size: ${bytes.length} bytes");
        final fileId = await _uploadFile(filename, bytes, 'assistants');
        print(
            "Successfully uploaded ${mat.name} (${bytes.length} bytes) → ID: $fileId");
        return fileId;
      }));

      // Step 2: Create a fresh vector store for each quiz generation
      final vectorStoreId = await _createVectorStore(fileIds);
      print(
          "Created vector store with ID: $vectorStoreId for ${fileIds.length} files");

      // Step 3: Create assistant once
      final assistantId = await _createAssistant(vectorStoreId);
      print("Created new assistant with ID: $assistantId for this quiz");

      // Step 4: Now only do the lightweight per‐run steps:
      final threadId = await _createThread();
      await _addMessageToThread(
          threadId,
          'First, CHECK what materials are available by searching for common terms like "the", "and", "introduction".\n\n' +
              'VERIFY you can read the content by quoting a few sentences from them.\n\n' +
              'Then create EXACTLY 10 multiple-choice questions ONLY from these materials.\n\n' +
              'Each question must include specific facts, concepts or information found in the materials.\n\n' +
              'IMPORTANT: If you cannot access the materials properly, indicate this clearly.');
      final runId = await _runAssistant(threadId, assistantId);
      await _pollRunStatus(threadId, runId);
      final raw = await _getMessages(threadId);
      print("Quiz generation completed. Response length: ${raw.length}");
      try {
        final parsedJson = jsonDecode(raw);

        // Check if questions array is empty and handle accordingly
        if (parsedJson["questions"] == null ||
            parsedJson["questions"].isEmpty) {
          throw Exception(
              "Quiz generation failed: No questions were created from the materials.");
        }

        return Quiz.fromJson(parsedJson);
      } catch (e) {
        print("Failed to parse JSON response: $e");
        print("Raw response: $raw");
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}
