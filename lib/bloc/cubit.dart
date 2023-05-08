import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/bloc/states.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../layout/screens/archive.dart';
import '../layout/screens/done.dart';
import '../layout/screens/tasks.dart';
import 'package:sqflite/sqflite.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];
  int index = 0;
  bool isBottomSheet = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> screens = [const Tasks(), const Done(), const Archive()];
  List<String> titleApp = ['New Tasks', 'Done Tasks', 'Archive Tasks'];
  var formKey = GlobalKey<FormState>();
  var taskController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var statusController = TextEditingController();
  IconData iconData = Icons.edit;
  Database? dataBase;

  void changeIndexBottomNavigationBar(int i) {
    index = i;
    emit(AppChangeIndexStates());
  }

  void floatingActionButtonOnPress({required IconData icon, required bool x}) {
    isBottomSheet = x;
    iconData = icon;
    emit(AppFloatingActionButtonStates());
  }

  void createDatabase() async {
    dataBase = await openDatabase('todo2.db', version: 1,
        onCreate: (database, version) async {
      await database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT NOT NULL, time TEXT NOT NULL , date TEXT NOT NULL, status TEXT NOT NULL)')
          .then((value) => {
                emit(AppCreateDatabaseStates()),
              })
          .catchError((error) {
        return error;
      });
    }, onOpen: (database) {
      getDatabase(database);
    });
  }

  Future insertDatabase(title, time, date) async {
    await dataBase!
        .transaction((txn) => txn.rawInsert(
            'INSERT INTO tasks (title,time,date,status) VALUES("$title","$time","$date","new")'))
        .then((value) => {
              getDatabase(dataBase),
              emit(AppInsertDatabaseStates()),
            })
        .catchError((error) {
          return error;
    });
  }

  void getDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];
    database.rawQuery('SELECT * FROM tasks').then((value) => {
          value.forEach((element) {
            if (element['status'] == 'new') {
              newTasks.add(element);
            } else if (element['status'] == 'done') {
              doneTasks.add(element);
            } else {
              archiveTasks.add(element);
            }
          }),
          emit(AppGetDatabaseStates()),
        });
  }

  Future updateDatabase({required int id, required String status,}) async {
    await dataBase!.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?', [
      status,
      id
    ]).then((value) => {
          getDatabase(dataBase),
          emit(AppUpdateDatabaseStates()),
        });
  }


  Future deleteDatabase({required int id,}) async {
    await dataBase!.rawUpdate('DELETE FROM tasks WHERE id = ?', [id]).then((value) => {
          getDatabase(dataBase),
          emit(AppDeleteDatabaseStates()),
        });
  }
}
