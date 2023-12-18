import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/procedure_provider.dart';
import 'package:makula_oem/views/widgets/makula_edit_text.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
class ProcedureScreen extends StatefulWidget {
  const ProcedureScreen({super.key});

  @override
  State<ProcedureScreen> createState() => _ProcedureScreenState();
}

class _ProcedureScreenState extends State<ProcedureScreen> {


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));
    final Map<String, dynamic> apiResponse = {
      "data": {
        "listOwnOemProcedureTemplates": [
          {
            "_id": "657aeba6979420471c7d90bd",
            "name": "Template Procedure 1",
            "description": "Template Procedure 1",
            "createdAt": "2023-12-14T11:48:54.799Z",
            "updatedAt": "2023-12-15T15:18:40.851Z",
            "signatures": [],
            "children": [
              {
                "_id": "657c6e50ceb78ef20802a3fe",
                "type": "HEADING",
                "name": "Test Heading 1",
                "description": null,
                "isRequired": false,
                "options": [],
                "tableOption": {"_id": null, "rowCount": null, "columns": []},
                "attachments": [],
                "children": []
              },
              {
                "_id": "657c6e50ceb78ef20802a3ff",
                "type": "SECTION",
                "name": "Test Section 1",
                "description": null,
                "isRequired": false,
                "options": [],
                "tableOption": {"_id": null, "rowCount": null, "columns": []},
                "attachments": [],
                "children": [
                  {
                    "_id": "657c6e50ceb78ef20802a400",
                    "type": "TEXT_AREA_FIELD",
                    "name": "Text Field",
                    "description": "This is a text Field",
                    "isRequired": true,
                    "options": [],
                    "tableOption": {"_id": null, "rowCount": null},
                    "attachments": []
                  },
                  {
                    "_id": "657c6e50ceb78ef20802a401",
                    "type": "NUMBER_FIELD",
                    "name": "Number Text Field",
                    "description": "This is a Number Text Field",
                    "isRequired": true,
                    "options": [],
                    "tableOption": {"_id": null, "rowCount": null},
                    "attachments": []
                  },
                  {
                    "_id": "657c6e50ceb78ef20802a402",
                    "type": "DATE_FIELD",
                    "name": "Date Picker Field",
                    "description": "This is a Date Picker Field",
                    "isRequired": true,
                    "options": [],
                    "tableOption": {"_id": null, "rowCount": null},
                    "attachments": []
                  },
                  {
                    "_id": "657c6e50ceb78ef20802a403",
                    "type": "CHECKLIST_FIELD",
                    "name": "Check List Field",
                    "description": "This is a Check List Field",
                    "isRequired": true,
                    "options": [
                      {"_id": "657c6e50ceb78ef20802a404", "name": "Option 1"},
                      {"_id": "657c6e50ceb78ef20802a405", "name": "Option 2"},
                      {"_id": "657c6e50ceb78ef20802a406", "name": "Option 3"},
                      {"_id": "657c6e50ceb78ef20802a407", "name": "Option 4"}
                    ],
                    "tableOption": {"_id": null, "rowCount": null},
                    "attachments": []
                  },
                  {
                    "_id": "657c6e50ceb78ef20802a408",
                    "type": "CHECKBOX_FIELD",
                    "name": "Check Box Field",
                    "description": "This is a Check Box Field",
                    "isRequired": true,
                    "options": [
                      {"_id": "657c6e50ceb78ef20802a409", "name": "Option 1"},
                      {"_id": "657c6e50ceb78ef20802a40a", "name": "Option 2"},
                      {"_id": "657c6e50ceb78ef20802a40b", "name": "Option 3"},
                      {"_id": "657c6e50ceb78ef20802a40c", "name": "Option 4"}
                    ],
                    "tableOption": {"_id": null, "rowCount": null},
                    "attachments": []
                  }
                ]
              },
              {
                "_id": "657c6e50ceb78ef20802a40d",
                "type": "HEADING",
                "name": "Test Heading 2",
                "description": null,
                "isRequired": false,
                "options": [],
                "tableOption": {"_id": null, "rowCount": null, "columns": []},
                "attachments": [],
                "children": []
              },
              {
                "_id": "657c6e50ceb78ef20802a40e",
                "type": "TEXT_AREA_FIELD",
                "name": "Text Field 2",
                "description": "This is a Text Field 2",
                "isRequired": false,
                "options": [],
                "tableOption": {"_id": null, "rowCount": null, "columns": []},
                "attachments": [],
                "children": []
              }
            ],
            "pageHeader": null
          }
        ]
      }
    };
    final List<dynamic> templates =
        apiResponse['data']['listOwnOemProcedureTemplates'];

    console("templates => ${templates.length}");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextView(
                    text: "Template Procedure 1",
                    textColor: Colors.black,
                    textFontWeight: FontWeight.bold,
                    fontSize: 16),
                const SizedBox(
                  height: 10,
                ),
                const TextView(
                    text: "Template Procedure 1",
                    textColor: Colors.black,
                    textFontWeight: FontWeight.normal,
                    fontSize: 12),
                for (var template in templates)
                  TemplateWidget(templateData: template),
                const SizedBox(height: 16),
                const ActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TemplateWidget extends StatelessWidget {
  final Map<String, dynamic> templateData;

  TemplateWidget({super.key, required this.templateData});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> templateChildren = templateData['children'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var child in templateChildren)
          FieldWidget(
            fieldData: child,
            isBorderShowing: true,
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            // Access the form state and get the values
            final formStateProvider = Provider.of<ProcedureProvider>(context, listen: false);
            formStateProvider.clearFieldValues();
            saveAsDraft();
          },
          child: const Text('Save as Draft'),
        ),
        ElevatedButton(
          onPressed: (){
            final formStateProvider = Provider.of<ProcedureProvider>(context, listen: false);
            if (formStateProvider.fieldValues.isNotEmpty) {
              finalize(formStateProvider.fieldValues);
            }
          },
          child: const Text('Finalize'),
        ),
      ],
    );
  }


  void saveAsDraft() {
    console('Saving as Draft');
  }

  void finalize(Map<String, dynamic> fieldValues) {
    console('Finalizing with values: $fieldValues');
  }
}

class FieldWidget extends StatelessWidget {
  final Map<String, dynamic> fieldData;
  final bool isBorderShowing;

  const FieldWidget(
      {super.key, required this.fieldData, required this.isBorderShowing});

  @override
  Widget build(BuildContext context) {
    final String type = fieldData['type'];
    final String name = fieldData['name'];
    final String description = fieldData['description'] ?? "";
    final bool isRequired = fieldData['isRequired'];

    switch (type) {
      case 'HEADING':
        return TextWidget(name: name, isRequired: isRequired);
      case 'TEXT_AREA_FIELD':
        return TextFieldWidget(
          name: name,
          isRequired: isRequired,
          keyboardType: TextInputType.text,
          description: description,
          isBorderShowing: isBorderShowing,
        );
      case 'NUMBER_FIELD':
        return TextFieldWidget(
          name: name,
          isRequired: isRequired,
          description: description,
          isBorderShowing: isBorderShowing,
          keyboardType: TextInputType.number,
        );
      case 'DATE_FIELD':
        return DatePickerWidget(name: name, isRequired: isRequired, description: description,);
      case 'SECTION':
        return SectionWidget(sectionData: fieldData);
      case 'CHECKLIST_FIELD':
        return ChecklistFieldWidget(fieldData: fieldData);
      case 'CHECKBOX_FIELD':
        return CheckboxFieldWidget(fieldData: fieldData);
      // Add more cases for other field types as needed
      default:
        return Container(); // Placeholder for unknown field types
    }
  }
}

class TextWidget extends StatelessWidget {
  final String name;
  final bool isRequired;

  const TextWidget({super.key, required this.name, required this.isRequired});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        TextView(
            text: name,
            textColor: Colors.black,
            textFontWeight: FontWeight.bold,
            fontSize: 16)
      ],
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final String name;
  final String description;
  final bool isRequired;
  final bool isBorderShowing;
  final TextInputType keyboardType;

  const TextFieldWidget(
      {super.key,
      required this.name,
      required this.description,
      required this.isBorderShowing,
      required this.isRequired,
      required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isBorderShowing
          ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
          : EdgeInsets.zero,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isBorderShowing ? 8 : 0),
          color: Colors.white,
          border: Border.all(
              color: isBorderShowing ? Colors.grey : Colors.white,
              width: isBorderShowing ? 0.4 : 0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: Colors.black,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          const SizedBox(
            height: 4,
          ),
          TextView(
              text: description,
              textColor: Colors.black,
              textFontWeight: FontWeight.w500,
              fontSize: 14),

          const SizedBox(
            height: 8,
          ),
          TextFormField(
            key: Key(name), // Use the field name as the key
            decoration: InputDecoration(labelText: name),
            keyboardType: keyboardType,
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
            onChanged: (value) {
              final formStateProvider = Provider.of<ProcedureProvider>(context, listen: false);
              formStateProvider.setFieldValue(name, value);
            },
          ),
          const SizedBox(
            height: 8,
          ),

          const Divider(),
          // TextField(
          //   keyboardType: keyboardType,
          // ),
        ],
      ),
    );
  }
}

class DatePickerWidget extends StatelessWidget {
  final String name;
  final String description;
  final bool isRequired;

  const DatePickerWidget({super.key, required this.name, required this.isRequired , required this.description});

  @override
  Widget build(BuildContext context) {
    DateTime? _selectedDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height:16,),
        TextView(
            text: "$name ${isRequired ? "*" : ""}",
            textColor: Colors.black,
            textFontWeight: FontWeight.normal,
            fontSize: 14),

        const SizedBox(
          height: 4,
        ),
        TextView(
            text: description,
            textColor: Colors.black,
            textFontWeight: FontWeight.w500,
            fontSize: 14),
        const SizedBox(
          height: 8,
        ),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null && pickedDate != _selectedDate) {
              // setState(() {
              //   _selectedDate = pickedDate;
              // });
              if (context.mounted) {
                // Save the value to the state
                final formStateProvider = Provider.of<ProcedureProvider>(context, listen: false);
                formStateProvider.setFieldValue(name, pickedDate);
              }

            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8)
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(text: "mm/dd/yyy", textColor: Colors.black, textFontWeight: FontWeight.normal, fontSize: 14),
                Icon(Icons.calendar_month)
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        const Divider(),
      ],
    );
  }
}

class SectionWidget extends StatelessWidget {
  final Map<String, dynamic> sectionData;

  const SectionWidget({super.key, required this.sectionData});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> sectionChildren = sectionData['children'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sectionData['name']),
          for (var child in sectionChildren)
            FieldWidget(
              fieldData: child,
              isBorderShowing: false,
            ),
        ],
      ),
    );
  }
}

class ChecklistFieldWidget extends StatelessWidget {
  final Map<String, dynamic> fieldData;

  const ChecklistFieldWidget({super.key, required this.fieldData});

  @override
  Widget build(BuildContext context) {
    final String name = fieldData['name'];
    final String description = fieldData['description'] ?? "";
    final bool isRequired = fieldData['isRequired'];
    final List<dynamic> options = fieldData['options'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16,),
        TextView(text: "$name ${isRequired ? "*" : ""}", textColor: Colors.black, textFontWeight: FontWeight.normal  , fontSize: 14),
        const SizedBox(
          height: 4,
        ),
        TextView(
            text: description,
            textColor: Colors.black,
            textFontWeight: FontWeight.w500,
            fontSize: 14),
        for (var option in options)
          CheckboxListTile(
            contentPadding: const EdgeInsets.all(0),
            title: TextView(text: "${option['name']}", textColor: Colors.black, textFontWeight: FontWeight.normal  , fontSize: 14),
            value: Provider.of<ProcedureProvider>(context).fieldValues[name]?.contains(option['name']) ?? false, // Set the actual value based on your logic
            onChanged: (value) {
              final formStateProvider = Provider.of<ProcedureProvider>(context, listen: false);

              if (value != null) {
                // Update the state with the selected options
                List<String> selectedOptions = List<String>.from(formStateProvider.fieldValues[name] ?? []);
                if (value) {
                  selectedOptions.add(option['name']);
                } else {
                  selectedOptions.remove(option['name']);
                }

                formStateProvider.setFieldValue(name, selectedOptions);
              }
            },
          ),
        const Divider()
      ],
    );
  }
}

class CheckboxFieldWidget extends StatelessWidget {
  final Map<String, dynamic> fieldData;

  const CheckboxFieldWidget({super.key, required this.fieldData});

  @override
  Widget build(BuildContext context) {
    final String name = fieldData['name'];
    final bool isRequired = fieldData['isRequired'];
    final String description = fieldData['description'] ?? "";
    final List<dynamic> options = fieldData['options'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16,),
        TextView(text: "$name ${isRequired ? "*" : ""}", textColor: Colors.black, textFontWeight: FontWeight.normal  , fontSize: 14),
        const SizedBox(
          height: 4,
        ),
        TextView(
            text: description,
            textColor: Colors.black,
            textFontWeight: FontWeight.w500,
            fontSize: 14),
        for (var option in options)
          CheckboxListTile(
            contentPadding: const EdgeInsets.all(0),
            title: TextView(text: "${option['name']}", textColor: Colors.black, textFontWeight: FontWeight.normal  , fontSize: 14),
            value: Provider.of<ProcedureProvider>(context).fieldValues[name]?.contains(option['name']) ?? false, // Set the actual value based on your logic
            onChanged: (value) {
              final formStateProvider = Provider.of<ProcedureProvider>(context, listen: false);

              if (value != null) {
                // Update the state with the selected options
                List<String> selectedOptions = List<String>.from(formStateProvider.fieldValues[name] ?? []);
                if (value) {
                  selectedOptions.add(option['name']);
                } else {
                  selectedOptions.remove(option['name']);
                }

                formStateProvider.setFieldValue(name, selectedOptions);
              }
            },
          ),
        const Divider()
      ],
    );
  }
}
