import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/features/course%20management/widgets/slcfilecard.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/Material.dart';
import 'package:slc/models/course_enrollment.dart';
import 'package:slc/repositories/course_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:path/path.dart' as path;

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

  // Helper method to convert CourseMaterial to file data for UI
  Map<String, dynamic> _materialToFile(CourseMaterial material) {
    FileType fileType = _getFileTypeFromMaterial(material);
    return {
      "fileType": fileType,
      "fileName": material.name,
      "fileSize": "N/A", // File size may not always be available
      "material": material, // Store the actual material for reference
      "isCompleted":
          widget.enrollment.completedMaterialIds.contains(material.id)
    };
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

  Future<void> _uploadFile() async {
    try {
      setState(() => _isLoading = true);

      // Pick file
      picker.FilePickerResult? result = await picker.FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get file details
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String extension = path.extension(fileName).replaceAll('.', '');

      // Create material object
      final materialId = DateTime.now().millisecondsSinceEpoch.toString();
      CourseMaterial material = CourseMaterial(
        id: materialId,
        name: fileName,
        downloadUrl: '', // Will be updated after upload
        type: extension,
      );

      // Upload file and add to course
      await _courseRepository.addMaterial(
        courseId: widget.course.id,
        CourseMaterial: material,
      );

      SLCFlushbar.show(
        context: context,
        message: "File uploaded successfully",
        type: FlushbarType.success,
      );

      // Refresh the state to show the new file
      setState(() {});
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Error uploading file: $e",
        type: FlushbarType.error,
      );
    } finally {
      setState(() => _isLoading = false);
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
    return widget.course.materials.map(_materialToFile).toList();
  }

  @override
  Widget build(BuildContext context) {
    final files = _materialsAsFiles;

    return _isLoading
        ? const Center(child: SLCLoadingIndicator(text: "Processing file..."))
        : SingleChildScrollView(
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
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
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
                                // Open file (implement file opening logic)
                                print("Opening file: ${file["fileName"]}");

                                // If not completed, mark as completed
                                if (!isCompleted) {
                                  await _markMaterialAsCompleted(material);
                                }
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
