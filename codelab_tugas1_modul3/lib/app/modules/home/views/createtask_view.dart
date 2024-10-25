import 'package:codelab_tugas1_modul3/app/modules/home/views/todolist_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CreateTaskScreen extends StatelessWidget {
  final bool isEdit; // Menentukan mode edit atau tambah
  final DocumentSnapshot? task; // Menyimpan data task yang ingin diedit

  // Constructor
  CreateTaskScreen({required this.isEdit, this.task});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    // Jika mode edit, isi controller dengan data task yang ada
    if (isEdit && task != null) {
      nameController.text = task!['name'] ?? ''; // Menghindari null
      descriptionController.text = task!['description'] ?? ''; // Menghindari null
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance FirestoreController yang sudah ada
    final FirestoreController firestoreController = Get.find<FirestoreController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'Create Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Simpan atau update task
              if (isEdit && task != null) {
                // Update task
                firestoreController.updateTask(task!.id, nameController.text, descriptionController.text);
              } else {
                // Tambah task baru
                firestoreController.addTask(nameController.text, descriptionController.text);
              }
              Get.back(result: true);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
    );
  }
}
