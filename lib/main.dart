import 'package:flutter/material.dart';

void main() => runApp(const MyApp());
class Task {
  String title;
  bool isCompleted;
  String? category;
  DateTime? dueDate;
  String? priority;

  Task({
    required this.title,
    this.isCompleted = false,
    this.category,
    this.dueDate,
    this.priority,
  });
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoListPage(), 
    );
  }
}

// 2. Your stateful home page
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController newTaskController = TextEditingController();
  
  List<Task> tasks = [
    Task(title: 'My first task', category: 'Work', priority: 'high'),
    Task(title: 'My second task', isCompleted: true, priority: 'low'),
  ]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo List')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Create New Task'),
                content: TextField(
                  controller: newTaskController,
                  decoration: const InputDecoration(hintText: 'Enter task name...'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      newTaskController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (newTaskController.text.isNotEmpty) {
                        setState(() {
                          tasks.add(Task(
                            title: newTaskController.text,
                            priority: 'medium',
                          ));
                        });
                        newTaskController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index]; 
          
          return TaskTile(
            title: task.title,
            isCompleted: task.isCompleted,
            category: task.category,
            dueDate: task.dueDate,
            priority: task.priority,
            onToggleCompleted: (bool? value) {
              setState(() {
                task.isCompleted = value ?? false; 
              });
            },
            onOptionsTapped: () {
              print("Options tapped for ${task.title}");
            },
          );
        }
      )
    );
  }
}