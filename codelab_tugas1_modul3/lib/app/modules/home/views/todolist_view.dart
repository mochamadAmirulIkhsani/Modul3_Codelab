import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'createtask_view.dart';

// Class untuk warna-warna tema aplikasi
class AppColor {
  Color colorPrimary = Colors.blue;
  Color colorSecondary = Colors.green;
  Color colorTertiary = Colors.orange;
}

// Class untuk latar belakang widget
class WidgetBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/background_image.png'), // Ubah sesuai dengan file yang tersedia
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class TodolistView extends StatelessWidget {
  final AppColor appColor = AppColor();
  final FirestoreController firestoreController = Get.put(FirestoreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColor.colorPrimary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WidgetBackground(),
            _buildWidgetListTodo(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          var result = await Get.to(() => CreateTaskScreen(isEdit: false));
          if (result != null && result) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Task has been created'),
            ));
            firestoreController.updateList();
          }
        },
        backgroundColor: appColor.colorTertiary,
      ),
    );
  }

  Widget _buildWidgetListTodo(BuildContext context) {
    return Obx(() {
      if (firestoreController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      return ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: firestoreController.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = firestoreController.tasks[index];
          String strDate = task['date'] ?? '';

          return Card(
            child: ListTile(
              title: Text(task['name'] ?? 'No name'),
              subtitle: Text(
                task['description'] ?? 'No description',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: appColor.colorSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${int.parse(strDate.split(' ')[0])}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    strDate.split(' ')[1] ?? '',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
                onSelected: (String value) {
                  if (value == 'edit') {
                    Get.to(() => CreateTaskScreen(isEdit: true, task: task));
                  } else if (value == 'delete') {
                    firestoreController.deleteTask(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Task has been deleted'),
                    ));
                  }
                },
                child: Icon(Icons.more_vert),
              ),
            ),
          );
        },
      );
    });
  }
}

class FirestoreController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var tasks = <DocumentSnapshot>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  void fetchTasks() async {
    isLoading(true);
    var snapshot = await firestore.collection('tasks').orderBy('date').get();
    tasks.assignAll(snapshot.docs);
    isLoading(false);
  }

  void updateList() {
    fetchTasks();
  }

  void deleteTask(String taskId) async {
    await firestore.collection('tasks').doc(taskId).delete();
    fetchTasks();
  }

  void addTask(String name, String description) async {
    await firestore.collection('tasks').add({
      'name': name,
      'description': description,
      'date': DateTime.now().toString(),
    });
    fetchTasks();
  }

  void updateTask(String taskId, String name, String description) async {
    await firestore.collection('tasks').doc(taskId).update({
      'name': name,
      'description': description,
      'date': DateTime.now().toString(),
    });
    fetchTasks();
  }
}
