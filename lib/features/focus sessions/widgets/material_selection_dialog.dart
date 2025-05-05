import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/models/Course.dart';
import 'package:slc/models/Material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MaterialSelectionDialog extends StatefulWidget {
  final Course course;
  final List<CourseMaterial> selectedMaterials;
  final int maxMaterials;
  final Function(List<CourseMaterial>) onMaterialsUpdated;

  const MaterialSelectionDialog({
    Key? key,
    required this.course,
    required this.selectedMaterials,
    required this.maxMaterials,
    required this.onMaterialsUpdated,
  }) : super(key: key);

  @override
  State<MaterialSelectionDialog> createState() =>
      _MaterialSelectionDialogState();
}

class _MaterialSelectionDialogState extends State<MaterialSelectionDialog> {
  late List<CourseMaterial> _tempSelectedMaterials;

  @override
  void initState() {
    super.initState();
    _tempSelectedMaterials = List.from(widget.selectedMaterials);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with course name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.selectMaterials(_tempSelectedMaterials.length, widget.maxMaterials) ?? 
                'Select Materials (${_tempSelectedMaterials.length}/${widget.maxMaterials})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Course title
          Text(
            '${widget.course.code}: ${widget.course.name}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: SLCColors.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // List of materials with checkboxes
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.course.materials.length,
              itemBuilder: (context, index) {
                final material = widget.course.materials[index];
                final isSelected = _tempSelectedMaterials.contains(material);

                return CheckboxListTile(
                  title: Text(material.name),
                  subtitle: Text(material.type),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        if (_tempSelectedMaterials.length <
                            widget.maxMaterials) {
                          _tempSelectedMaterials.add(material);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  l10n?.maxMaterialsLimit(widget.maxMaterials) ?? 'You can select up to ${widget.maxMaterials} materials'),
                            ),
                          );
                        }
                      } else {
                        _tempSelectedMaterials.remove(material);
                      }
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Save button
          Center(
            child: SLCButton(
              onPressed: () {
                widget.onMaterialsUpdated(_tempSelectedMaterials);
                Navigator.of(context).pop();
              },
              backgroundColor: SLCColors.primaryColor,
              foregroundColor: Colors.white,
              text: l10n?.done ?? "Done",
              width: 150,
            ),
          ),
        ],
      ),
    );
  }
}
