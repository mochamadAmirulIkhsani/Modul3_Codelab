import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../auth/background/views/widget_background.dart';
import '../../auth/color/views/app_color.dart';

class CreateTaskScreen extends StatefulWidget {
  final bool isEdit;
  final String documentId;
  final String name;
  final String description;
  final String date;

  CreateTaskScreen({
    required this.isEdit,
    this.documentId = '',
    this.name = '',
    this.description = '',
    this.date = '',
  });

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AppColor appColor = AppColor();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  final TextEditingController controllerDate = TextEditingController();

  late DateTime date;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    date = widget.isEdit ? DateFormat('dd MMMM yyyy').parse(widget.date) : DateTime.now().add(Duration(days: 1));
    controllerName.text = widget.name;
    controllerDescription.text = widget.description;
    controllerDate.text = widget.isEdit
        ? widget.date
        : DateFormat('dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor.colorPrimary,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WidgetBackground(),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.grey[800]),
          ),
          SizedBox(height: 16.0),
          Text(
            widget.isEdit ? 'Edit\nTask' : 'Create\nNew Task',
            style: Theme.of(context).textTheme.headlineMedium!.merge(
              TextStyle(color: Colors.grey[800]),
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: controllerName,
            decoration: InputDecoration(labelText: 'Name'),
            style: TextStyle(fontSize: 18.0),
          ),
          TextField(
            controller: controllerDescription,
            decoration: InputDecoration(labelText: 'Description'),
            style: TextStyle(fontSize: 18.0),
          ),
          TextField(
            controller: controllerDate,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              suffixIcon: Icon(Icons.today),
            ),
            style: TextStyle(fontSize: 18.0),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  date = pickedDate;
                  controllerDate.text = DateFormat('dd MMMM yyyy').format(date);
                });
              }
            },
          ),
          SizedBox(height: 16.0),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildCreateOrUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildCreateOrUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColor.colorTertiary,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(widget.isEdit ? 'UPDATE TASK' : 'CREATE TASK'),
        onPressed: () async {
          if (controllerName.text.isEmpty || controllerDescription.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Name and description are required')),
            );
            return;
          }

          setState(() => isLoading = true);
          try {
            if (widget.isEdit) {
              await firestore.collection('tasks').doc(widget.documentId).update({
                'name': controllerName.text,
                'description': controllerDescription.text,
                'date': controllerDate.text,
              });
            } else {
              await firestore.collection('tasks').add({
                'name': controllerName.text,
                'description': controllerDescription.text,
                'date': controllerDate.text,
              });
            }
            Navigator.pop(context, true);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save task')),
            );
          } finally {
            setState(() => isLoading = false);
          }
        },
      ),
    );
  }
}
