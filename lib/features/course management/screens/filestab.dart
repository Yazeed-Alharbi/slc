import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/features/course%20management/widgets/slcfilecard.dart';

class FilesTab extends StatefulWidget {
  @override
  _FilesTabState createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  List<Map<String, dynamic>> files = [
    {
      "fileType": FileType.PPT,
      "fileName": "Chapter 1 - Introduction to PM",
      "fileSize": "20 MB"
    },
    {
      "fileType": FileType.PDF,
      "fileName": "Lecture Notes",
      "fileSize": "15 MB"
    },
    {"fileType": FileType.DOC, "fileName": "Assignment 1", "fileSize": "5 MB"},
  ];

  void _deleteFile(int index) {
    String fileName = files[index]["fileName"];

    setState(() {
      files.removeAt(index);
    });

    SLCFlushbar.show(
      context: context,
      message: "$fileName deleted successfully",
      type: FlushbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    // Implement file upload logic
                  },
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
            Column(
              children: files.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> file = entry.value;

                return Dismissible(
                  key: Key(file["fileName"]),
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
                      _deleteFile(index);
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
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: SLCFileCard(
                      fileType: file["fileType"],
                      fileName: file["fileName"],
                      fileSize: file["fileSize"],
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
