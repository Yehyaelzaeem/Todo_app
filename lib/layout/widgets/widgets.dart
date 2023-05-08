import 'package:flutter/material.dart';
import 'package:todo/bloc/cubit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

import '../../model/model.dart';

Widget defaultFormTextField({
  required TextEditingController textEditingController,
  TextInputType textInputType = TextInputType.text,
  required String? Function(String?)? validator,
  required String lable,
  required IconData iconData,
  void Function()? onTap,
  void Function(String)? onChanged,
  void Function(String)? onFieldSubmitted,
}) =>
    TextFormField(
      style: const TextStyle(fontSize: 18),
      keyboardType: textInputType,
      controller: textEditingController,
      validator: validator,
      decoration: InputDecoration(
          labelText: lable,
          prefixIcon: Icon(
            iconData,
            color: Colors.grey.shade600,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          )),
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );




Widget defaultTaskItems(TasksModel tasksModel,context) =>
    Dismissible(
      key: Key(tasksModel.id.toString()),
      onDismissed: (dir){
        AppCubit.get(context).deleteDatabase(id: tasksModel.id);
      },
      background: Container(
        color: Colors.red[400],
        padding: const EdgeInsets.only(right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const <Widget>[
            Icon(
              Icons.delete,
              size: 35,
            )
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0,right: 10,top: 15,bottom: 15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 45.0,
              child: Text(
                tasksModel.time,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tasksModel.title,
                  style: const TextStyle(fontSize: 18,),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(tasksModel.date,
                    style: TextStyle(fontSize: 13,color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            IconButton(onPressed: (){
             AppCubit.get(context).updateDatabase(id:tasksModel.id, status: 'done');
            }, icon: Icon(Icons.check_box,color: Colors.green[400],)),
            IconButton(onPressed: (){
              AppCubit.get(context).updateDatabase(id:tasksModel.id, status: 'archive');
            }, icon: Icon(Icons.archive_outlined,color: Colors.grey[600],))
          ],
        ),
      ),
    )
;




Widget defaultTasks({required List tasks}
    )=>  ConditionalBuilder(
    condition: tasks.isNotEmpty,
    builder: (context)=> ListView.separated(
        itemBuilder: (context,i)=>
            defaultTaskItems(
              TasksModel(
                  id: tasks[i]['id'],
                  title:'${tasks[i]['title']}',
                  time: '${tasks[i]['time']}',
                  date: '${tasks[i]['date']}',
                  status: '${tasks[i]['status']}'),
              context,

            ),
        separatorBuilder: (context,index)=>Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey,
        ),
        itemCount: tasks.length),
    fallback: (context)=>Center(child:
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.menu,size: 100,color: Colors.grey,),
        Text('No Tasks Yet, Please Add Some Tasks',
          style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.grey),
        )
      ],
    ),));