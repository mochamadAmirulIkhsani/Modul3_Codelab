import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX untuk state management
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var tasks = <DocumentSnapshot>[].obs;
  var isLoading = true.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
