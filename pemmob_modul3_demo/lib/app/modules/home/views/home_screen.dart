import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../auth/background/views/widget_background.dart';
import '../../auth/color/views/app_color.dart';
import '../../task/views/create_task_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AppColor appColor = AppColor();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;

    return Scaffold(
      key: scaffoldState,
      backgroundColor: appColor.colorPrimary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WidgetBackground(),
            _buildWidgetListTodo(widthScreen, heightScreen, context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTaskScreen(isEdit: false),
            ),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Task has been created'),
            ));
            setState(() {});
          }
        },
        backgroundColor: appColor.colorTertiary,
      ),
    );
  }

  Widget _buildWidgetListTodo(
      double widthScreen, double heightScreen, BuildContext context) {
    return Container(
      width: widthScreen,
      height: heightScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Text(
              'Todo List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('tasks').orderBy('date').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> task =
                    document.data() as Map<String, dynamic>;
                    String strDate = task['date'] ?? '';

                    return Card(
                      child: ListTile(
                        title: Text(task['name'] ?? 'No Title'),
                        subtitle: Text(
                          task['description'] ?? 'No Description',
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
                                  '${int.parse(strDate.split(' ')[0] ?? '0')}',
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
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateTaskScreen(
                                    isEdit: true,
                                    documentId: document.id,
                                    name: task['name'],
                                    description: task['description'],
                                    date: strDate,
                                  ),
                                ),
                              );
                              if (result == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task has been updated'),
                                  ),
                                );
                              }
                            } else if (value == 'delete') {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete this task?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              ) ?? false;

                              if (confirmDelete) {
                                await firestore
                                    .collection('tasks')
                                    .doc(document.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task has been deleted'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
