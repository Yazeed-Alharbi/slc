import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';

// Enum should be declared outside the class
enum FileType { PPT, PDF, DOC, XLS, ZIP, IMG, OTHER }

class SLCFileCard extends StatelessWidget {
  final FileType fileType;
  final String fileName;
  final String fileSize;

  const SLCFileCard({
    Key? key,
    required this.fileType,
    required this.fileName,
    required this.fileSize, required bool isCompleted, required Future<Null> Function() onPressed,
  }) : super(key: key);

  String getFileIcon() {
    switch (fileType) {
      case FileType.PDF:
        return "assets/PDFIcon.png";
      case FileType.DOC:
        return "assets/DOCIcon.png";
      case FileType.PPT:
      default:
        return "assets/PPTIcon.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            getFileIcon(), // Use the method to get the correct icon
            width: 35,
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName, // Dynamic file name
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                fileSize, // Dynamic file size
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: SLCColors.coolGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
