import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyTaskify extends StatelessWidget {
  const MyTaskify({super.key, 
  required this.taskName, 
  required this.taskCompleted, 
  required this.onChanged,
  required this.deleteFunction});

  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: Slidable(
         endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(onPressed: deleteFunction,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.orangeAccent,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                checkColor: Colors.black,
                activeColor: Colors.white,
                side:const BorderSide(
                  color: Colors.white,
                ),
              ),
              Text(
                taskName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  decoration: taskCompleted 
                  ? TextDecoration.lineThrough 
                  : TextDecoration.none,
                  decorationColor: Colors.black,
                  decorationThickness: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
