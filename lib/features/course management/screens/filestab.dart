import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/course%20management/widgets/slcfilecard.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/models/Material.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:path/path.dart' as path;
import 'dart:math';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FilesTab extends StatefulWidget {
  final Course course;
  final CourseEnrollment enrollment;

  const FilesTab({
    Key? key,
    required this.course,
    required this.enrollment,
  }) : super(key: key);

  @override
  _FilesTabState createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  final CourseRepository _courseRepository = CourseRepository(
    firestoreUtils: FirestoreUtils(),
  );

  bool _isLoading = false;
  bool _isOpeningFile = false; // New separate state for file opening
  String _currentFileName = "";
  double _uploadProgress = 0.0;

  // Helper method to convert CourseMaterial to file data for UI
  Map<String, dynamic> _materialToFile(CourseMaterial material) {
    FileType fileType = _getFileTypeFromMaterial(material);
    return {
      "fileType": fileType,
      "fileName": material.name,
      "fileSize": _formatFileSize(material.fileSize),
      "material": material, // Store the actual material for reference
      "isCompleted":
          widget.enrollment.completedMaterialIds.contains(material.id)
    };
  }

  // Helper method to format file size to human-readable format
  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";

    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Helper to determine FileType from Material
  FileType _getFileTypeFromMaterial(CourseMaterial material) {
    String extension = material.type.toLowerCase();
    if (extension == "pdf") return FileType.PDF;
    if (extension == "ppt" || extension == "pptx") return FileType.PPT;
    if (extension == "doc" || extension == "docx") return FileType.DOC;
    if (extension == "xls" || extension == "xlsx") return FileType.XLS;
    if (extension == "zip" || extension == "rar") return FileType.ZIP;
    if (extension == "jpg" || extension == "jpeg" || extension == "png")
      return FileType.IMG;
    return FileType.OTHER;
  }

  Future<void> _openFile(CourseMaterial material, String fileName) async {
    try {
      print("Starting to open file: $fileName");
      setState(() {
        _isOpeningFile = true; // Use this instead of _isLoading
        _currentFileName = fileName;
      });

      // Download file to temporary storage
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      print("File path: $filePath");

      // Check if file exists already
      if (!await file.exists()) {
        print("File doesn't exist, downloading from: ${material.downloadUrl}");
        // Download file from URL
        final response = await http.get(Uri.parse(material.downloadUrl));
        await file.writeAsBytes(response.bodyBytes);
        print("File downloaded, size: ${response.bodyBytes.length} bytes");
      } else {
        print("File already exists, size: ${await file.length()} bytes");
      }

      // Verify file exists and has content
      if (!await file.exists() || await file.length() == 0) {
        throw Exception("File download failed or file is empty");
      }

      print("Opening file with MIME type: ${_getMimeType(material.type)}");

      // Open file with device's default app
      final result = await OpenFile.open(
        filePath,
        type: _getMimeType(material.type),
      );

      print("OpenFile result: ${result.type} - ${result.message}");

      if (result.type != ResultType.done) {
        // Handle error
        SLCFlushbar.show(
          context: context,
          message: "Could not open file: ${result.message}",
          type: FlushbarType.error,
        );
      }
    } catch (e) {
      print("Error opening file: $e");
      SLCFlushbar.show(
        context: context,
        message: "Error opening file: $e",
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningFile = false); // Reset opening state
      }
    }
  }

// Helper to get MIME type for different file extensions
  String _getMimeType(String extension) {
    extension = extension.toLowerCase();

    // Common MIME types map
    final mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  Future<void> _uploadFile() async {
    try {
      // Pick multiple files
      picker.FilePickerResult? result =
          await picker.FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: picker.FileType.custom,
        allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      setState(() => _isLoading = true);

      // Iterate over each selected file
      for (var pickedFile in result.files) {
        if (pickedFile.path == null) continue;

        // Get file details
        File file = File(pickedFile.path!);
        int fileSizeInBytes = await file.length();
        String fileName = pickedFile.name;
        String extension = path.extension(fileName).replaceAll('.', '');

        // Update UI with current file name and reset progress
        setState(() {
          _currentFileName = fileName;
          _uploadProgress = 0.0;
        });

        // Upload file to Firebase Storage with progress tracking
        String downloadUrl = await _courseRepository.uploadFileToStorage(
          file: file,
          courseId: widget.course.id,
          onProgress: (progress) {
            // Important: Update the UI when progress changes
            if (mounted) {
              setState(() {
                _uploadProgress = progress;
              });
            }
          },
        );

        // Create CourseMaterial object
        final materialId = DateTime.now().millisecondsSinceEpoch.toString();
        CourseMaterial material = CourseMaterial(
          id: materialId,
          name: fileName,
          fileSize: fileSizeInBytes,
          downloadUrl: downloadUrl,
          type: extension,
        );

        // Add material to Firestore
        await _courseRepository.addMaterial(
          courseId: widget.course.id,
          CourseMaterial: material,
        );
      }

      // Success message
      SLCFlushbar.show(
        context: context,
        message: "Files uploaded successfully",
        type: FlushbarType.success,
      );

      // Refresh UI to show the newly added files
      setState(() {});
    } catch (e) {
      // Handle errors
      SLCFlushbar.show(
        context: context,
        message: "Error uploading file: $e",
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentFileName = "";
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _deleteFile(int index) async {
    Map<String, dynamic> fileData = _materialsAsFiles[index];
    CourseMaterial material = fileData["material"];

    try {
      await _courseRepository.removeMaterial(
        courseId: widget.course.id,
        materialId: material.id,
      );

      SLCFlushbar.show(
        context: context,
        message: "${fileData["fileName"]} deleted successfully",
        type: FlushbarType.success,
      );

      // Refresh the state to remove the deleted file
      setState(() {});
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Error deleting file: $e",
        type: FlushbarType.error,
      );
    }
  }

  Future<void> _markMaterialAsCompleted(CourseMaterial material) async {
    try {
      await _courseRepository.markMaterialAsCompleted(
        enrollmentId: widget.enrollment.id,
        materialId: material.id,
      );

      SLCFlushbar.show(
        context: context,
        message: "Material marked as completed",
        type: FlushbarType.success,
      );

      // Refresh the state to update completion status
      setState(() {});
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Error marking as completed: $e",
        type: FlushbarType.error,
      );
    }
  }

  // Get materials converted to files for UI
  List<Map<String, dynamic>> get _materialsAsFiles {
    return widget.course.materials
        .map((material) => _materialToFile(material))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final files = _materialsAsFiles;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SLCLoadingIndicator(text: "Uploading $_currentFileName"),
            const SizedBox(height: 16),
            Text(
              "${(_uploadProgress * 100).toStringAsFixed(1)}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[300],
                valueColor:
                    AlwaysStoppedAnimation<Color>(SLCColors.primaryColor),
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    } else if (_isOpeningFile) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SLCLoadingIndicator(text: "Opening $_currentFileName"),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: SpacingStyles(context).defaultPadding,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SLCButton(
                    width: MediaQuery.sizeOf(context).width * 0.2,
                    onPressed: _uploadFile,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    text: "Upload File",
                    backgroundColor: SLCColors.primaryColor,
                    foregroundColor: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 35,
                  )
                ],
              ),
              const SizedBox(height: 10),

              // Show empty state if no files
              if (files.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No files uploaded yet",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Upload course materials using the button above",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Show files if available
              if (files.isNotEmpty)
                Column(
                  children: files.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> file = entry.value;
                    CourseMaterial material = file["material"];
                    bool isCompleted = file["isCompleted"] ?? false;

                    return Dismissible(
                      key: Key(material.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        bool confirm = await NativeAlertDialog.show(
                          context: context,
                          title: "Delete File",
                          content:
                              "Are you sure you want to delete '${file["fileName"]}'?",
                          confirmText: "Delete",
                          confirmTextColor: Colors.red,
                          cancelText: "Cancel",
                        );
                        if (confirm) {
                          await _deleteFile(index);
                        }
                        return confirm;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 60,
                          child: Container(
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.centerRight,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SLCFileCard(
                          fileType: file["fileType"],
                          fileName: file["fileName"],
                          fileSize: file["fileSize"],
                          isCompleted: isCompleted,
                          onPressed: () async {
                            // Get material details
                            CourseMaterial material = file["material"];
                            String fileName = file["fileName"];

                            // Open file
                            await _openFile(material, fileName);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      );
    }
  }
}
