import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:todo/bloc/cubit.dart';
import 'package:todo/bloc/states.dart';
import 'widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit,AppStates>(
          builder: (context, state) {
            AppCubit cubit =AppCubit.get(context);
            return Scaffold(
              key: cubit.scaffoldKey,
              appBar: AppBar(
                backgroundColor: Colors.blue,
                title:  Center(child: Text(cubit.titleApp[cubit.index])),
              ),
              body:
              ConditionalBuilder(
                  condition: true,
                  builder: (context)=>cubit.screens[cubit.index],
                  fallback: (context)=>const Center(child: CircularProgressIndicator(),)),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isBottomSheet == true) {
                    if (cubit.formKey.currentState!.validate()) {
                      cubit.insertDatabase(cubit.taskController.text, cubit.timeController.text,
                          cubit.dateController.text)
                          .then((value) => {
                          cubit.floatingActionButtonOnPress(icon: Icons.edit, x: false),
                                cubit.taskController.text = '',
                                cubit.timeController.text = '',
                                cubit.dateController.text = '',
                              });
                    }
                  } else {
                    cubit.scaffoldKey.currentState!.showBottomSheet(
                      (context) => WillPopScope(
                          onWillPop: () {
                            cubit.floatingActionButtonOnPress(icon: Icons.edit, x: false);
                            return Future.value(true);
                          },
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: cubit.formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultFormTextField(
                                      textEditingController: cubit.taskController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'must be is not empty';
                                        }
                                        return null;
                                      },
                                      lable: 'Task Title',
                                      iconData: Icons.title),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  defaultFormTextField(
                                      textInputType: TextInputType.datetime,
                                      textEditingController: cubit.timeController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'must be is not empty';
                                        }
                                        return null;
                                      },
                                      onTap: () {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now())
                                            .then((value) => {
                                                  cubit.timeController.text =
                                                      value!.format(context),
                                                });
                                      },
                                      lable: 'Task Time',
                                      iconData: Icons.watch_later_outlined),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  defaultFormTextField(
                                      textInputType: TextInputType.datetime,
                                      textEditingController: cubit.dateController,
                                      onTap: () {
                                        var date = DateTime.now();
                                        var newDate = DateTime(date.year,
                                            date.month + 1, date.day);
                                        showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.parse(
                                                    newDate.toString()))
                                            .then((value) => {
                                                  cubit.dateController.text =
                                                      DateFormat.yMMMd()
                                                          .format(value!)
                                                });
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'must be is not empty';
                                        }
                                        return null;
                                      },
                                      lable: 'Task Date',
                                      iconData: Icons.calendar_today),
                                ],
                              ),
                            ),
                          )),
                      elevation: 50.0,
                      enableDrag: true,
                    ).closed.then((value) => {
                      cubit.floatingActionButtonOnPress(icon: Icons.edit, x: false),
                    });
                    cubit.floatingActionButtonOnPress(icon: Icons.add, x: true);
                  }
                },
                child: Icon(cubit.iconData),
              ),
              bottomNavigationBar: BottomNavigationBar(
                elevation: 50.0,
                currentIndex: cubit.index,
                onTap: (i) {
                  cubit.changeIndexBottomNavigationBar(i);
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: 'Tasks'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline), label: 'Done'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined), label: 'Archived')
                ],
              ),
            );
          },
          listener: (context, state) {
            if(state is AppInsertDatabaseStates){
              Navigator.pop(context);
            }

          }),
    );
  }
}
