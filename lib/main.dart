import 'package:flutter/material.dart';

void main() => runApp(const MyApp());
String  appBarText = 'To Do List';
/// Global list defining the  priority levels for tasks.
List<String> priorityList = ['high', 'medium', 'low'];

/// Enum representing the available categories for tasks.
enum Category { home, robotics, school }

/// getting values for tasks 
class Task {
  String title;

  bool isCompleted;

  String? category;

  DateTime? dueDate;

  String? priority;

  /// requiring certin values 
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //backgroundColor
        scaffoldBackgroundColor: const Color(0xFF121212),
        //setting colors for the app
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        //making the appbar background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  final TextEditingController newTaskController = TextEditingController();

  final TextEditingController dateInputController = TextEditingController();

  /// pre-loaded tasks displayed when the app launches.
  List<Task> tasks = [
    Task(
      title: 'Aaa',
      category: 'Home',
      priority: 'high',
      dueDate: DateTime(2023, 5, 23),
    ),
    Task(
      title: 'BBbb',
      category: 'Robotics',
      priority: 'medium',
      dueDate: DateTime(2026, 8, 30),
    ),
  ];

  /// Getter that returns a sorted list of all category names with their first letters capitalized.
  List<String> get categoryList {
    final categories = Category.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return categories
        .map((c) => c.name[0].toUpperCase() + c.name.substring(1))
        .toList();
  }

  // gets a impot for a custom date string in 'dd/mm/yyyy' format (with support for 2-digit years). returing null if something is empty or invalid
   DateTime? parseCustomDate(String input) {
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) return null;
    final parts = cleanInput.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    var year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    // Handle 2-digit years by assuming the 21st century (2000+)
    if (year < 100) {
      year += 2000;
    }

    // Attempt to construct and return the DateTime object
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  /// Sorts the tasks list by urgency in place and updates the UI
  void sortByUrgency() {
    final priorityRank = {'high': 1, 'medium': 2, 'low': 3};
    setState(() {
      tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
//if the duedate is empty return null 
        if (a.dueDate != null && b.dueDate != null) {
          final dateCompare = a.dueDate!.compareTo(b.dueDate!);
          if (dateCompare != 0) return dateCompare;
        } else if (a.dueDate != null) {
          return -1;
        } else if (b.dueDate != null) {
          return 1;
        }

        final rankA = priorityRank[a.priority?.toLowerCase()] ?? 4;
        final rankB = priorityRank[b.priority?.toLowerCase()] ?? 4;
        return rankA.compareTo(rankB);
      });
    });
  }

  /// Sorts the tasks list by category name alphabetically in place and updates the UI.
  void sortByCategory() {
    setState(() {
      tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
//making category lowerCase and then sorting it and returns null if its invalid or empty
        if (a.category != null && b.category != null) {
          return a.category!.toLowerCase().compareTo(b.category!.toLowerCase());
        } else if (a.category != null) {
          return -1;
        } else if (b.category != null) {
          return 1;
        }

        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryList;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          //sort by Urgency button
          icon: const Icon(Icons.sort_rounded, color: Colors.white,),
          tooltip: 'Sort by Urgency',
          onPressed: sortByUrgency,
        ),
        
        title: Text(
          //checking if there arent any tasks and if there arent any it changes  the app to say [No Tasks Found]
          tasks.isEmpty ? 'No tasks found.' : 'My Tasks',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        ),
        actions: [
          IconButton(
            //category sort button
            icon: const Icon(Icons.category_outlined, color:  Colors.white,),
            tooltip: 'Sort by Category',
            onPressed: sortByCategory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          String? nameErrorMessage;
          String? dateErrorMessage;
          String selectedPriority = priorityList[0];
          String? selectedCategory = categories.isNotEmpty
              ? categories[0]
              : null;
          //Add tasks menu
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      'Create New Task',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: newTaskController,
                            decoration: InputDecoration(
                              hintText: 'Enter task name...',
                              errorText: nameErrorMessage,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          //date input area inside of add task menu
                          const SizedBox(height: 16),
                          TextField(
                            controller: dateInputController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              hintText: '(e.g. 23/5/26)',
                              labelText: 'Due Date (DD/M/YY)',
                              errorText: dateErrorMessage,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                //calendar button 
                                icon: const Icon(Icons.calendar_month),
                                onPressed: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      //show error if the date is empty
                                  if (pickedDate != null) {
                                    setDialogState(() {
                                      dateInputController.text =
                                          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year % 100}';
                                      dateErrorMessage = null;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          //drop down menu for the prioritys
                          const SizedBox(height: 16),
                          DropdownMenu<String>(
                            initialSelection: priorityList[0],
                            label: const Text('Priority'),
                            onSelected: (String? value) {
                              if (value != null) {
                                selectedPriority = value;
                              }
                            },
                            dropdownMenuEntries: [
                              for (var priority in priorityList)
                                DropdownMenuEntry<String>(
                                  value: priority,
                                  label:
                                      priority[0].toUpperCase() +
                                      priority.substring(1),
                                ),
                            ],
                          ),
                          //drop down menu for the category
                          const SizedBox(height: 16),
                          DropdownMenu<String>(
                            initialSelection: selectedCategory,
                            label: const Text('Category'),
                            onSelected: (String? value) {
                              if (value != null) {
                                selectedCategory = value;
                              }
                            },
                            dropdownMenuEntries: [
                              for (var category in categories)
                                DropdownMenuEntry<String>(
                                  value: category,
                                  label: category,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //tasks add menu cancel button
                    actions: [
                      TextButton(
                        onPressed: () {
                          newTaskController.clear();
                          dateInputController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final nameText = newTaskController.text.trim();
                          final dateText = dateInputController.text.trim();
                          DateTime? parsedDate;
                          bool hasDateError = false;

                          if (dateText.isNotEmpty) {
                            parsedDate = parseCustomDate(dateText);
                            if (parsedDate == null) {
                              hasDateError = true;
                            }
                          }

                          if (nameText.isNotEmpty && !hasDateError) {
                            setState(() {
                              tasks.add(
                                Task(
                                  title: nameText,
                                  priority: selectedPriority,
                                  category: selectedCategory,
                                  dueDate: parsedDate,
                                ),
                              );
                            });
                            newTaskController.clear();
                            dateInputController.clear();
                            Navigator.pop(context);
                          } else {
                            setDialogState(() {
                              nameErrorMessage = nameText.isEmpty
                                  ? 'Task name cannot be empty!'
                                  : null;
                              dateErrorMessage = hasDateError
                                  ? 'Invalid format. Use DD/M/YY (23/5/26)'
                                  : null;
                            });
                          }
                        },
                        child: const Text('Add Task'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        //confiorm adding the task
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
            onDeleteTapped: () {
              setState(() {
                tasks.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  //setting value for the task
  final String title;

  final bool isCompleted;

  final String? category;

  final DateTime? dueDate;

  final String? priority;

  final ValueChanged<bool?>? onToggleCompleted;

  final VoidCallback? onDeleteTapped;

  const TaskTile({
    //require ceriten values
    super.key,
    required this.title,
    this.isCompleted = false,
    this.category,
    this.dueDate,
    this.priority,
    this.onToggleCompleted,
    this.onDeleteTapped,
  });

//formating the date input to look good
  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    //returning a month and removing 1 because the list starts storing at [0]
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Returns a color corresponding to the given task priority level.
  Color getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = getPriorityColor(priority);
  //setting the time now
    final now = DateTime.now();
    //setting the time for this midnight
    final todayMidnight = DateTime(now.year, now.month, now.day);
//setting the midnight for midnight in the dueDate 
    final targetMidnight = dueDate != null

        ? DateTime(dueDate!.year, dueDate!.month, dueDate!.day)
        : null;
    final isOverdue =
        targetMidnight != null &&
        targetMidnight.isBefore(todayMidnight) &&
        !isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Material(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (onToggleCompleted != null) {
              onToggleCompleted!(!isCompleted);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: onToggleCompleted,
                  activeColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isCompleted
                              ? Colors.grey.shade600
                              : Colors.white,
                        ),
                      ),
                      if (category != null ||
                          dueDate != null ||
                          priority != null) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.deepPurple.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  category!,
                                  style: const TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (dueDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.blueGrey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isOverdue
                                        ? Colors.red.withValues(alpha: 0.3)
                                        : Colors.blueGrey.withValues(
                                            alpha: 0.3,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isOverdue
                                          ? Icons.warning_amber_rounded
                                          : Icons.calendar_today_rounded,
                                      size: 12,
                                      color: isOverdue
                                          ? Colors.redAccent
                                          : Colors.blueGrey.shade200,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatDate(dueDate!),
                                      style: TextStyle(
                                        color: isOverdue
                                            ? Colors.redAccent
                                            : Colors.blueGrey.shade200,
                                        fontSize: 11,
                                        fontWeight: isOverdue
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (priority != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: priorityColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  priority![0].toUpperCase() +
                                      priority!.substring(1),
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: onDeleteTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
