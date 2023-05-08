import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/bloc/cubit.dart';
import 'package:todo/bloc/states.dart';
import '../widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Tasks extends StatelessWidget {
  const Tasks({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
        builder: (context,state){
          var tasks =AppCubit.get(context).newTasks;
          return
            defaultTasks(tasks: tasks);
        },
        listener: (context,state){});
  }
}
