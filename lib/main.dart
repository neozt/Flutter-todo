import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      home: const ToDoList(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 189, 182, 40),
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final _todos = <TodoEntry>[];
  final _deleted = <TodoEntry>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  final _strikedThroughFont =
      const TextStyle(fontSize: 18, decoration: TextDecoration.lineThrough);

  void _showDeleted() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      // Render tiles in reversed order so that most recently deleted entries appead at the top
      final tiles = <ListTile>[];
      for (var i = _deleted.length - 1; i >= 0; i--) {
        final entry = _deleted[i];
        tiles.add(
          ListTile(
            title: Text(
              entry.content,
              style: entry.isCompleted ? _strikedThroughFont : _biggerFont,
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.restart_alt,
                semanticLabel: 'Restore',
              ),
              onPressed: () {
                _restore(i);
                // Manually re-render deleted page to update
                Navigator.of(context).pop();
                _showDeleted();
              },
            ),
          ),
        );
      }
      final divided = tiles.isNotEmpty
          ? ListTile.divideTiles(
              context: context,
              tiles: tiles,
            ).toList()
          : <Widget>[];

      return Scaffold(
        appBar: AppBar(
          title: const Text('Deleted Todos'),
        ),
        body: ListView(children: divided),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _showDeleted,
            tooltip: 'Show deleted todos',
          ),
        ],
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _todos.length * 2,
          itemBuilder: (context, i) {
            if (i.isOdd) {
              return const Divider(
                height: 2,
              );
            }

            final index = i ~/ 2;
            final entry = _todos[index];

            return ListTile(
              title: Text(
                entry.content,
                style: entry.isCompleted ? _strikedThroughFont : _biggerFont,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  semanticLabel: 'Delete todo',
                ),
                onPressed: () {
                  _delete(index);
                },
              ),
              leading: IconButton(
                  icon: Icon(
                    entry.isCompleted
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    semanticLabel: entry.isCompleted
                        ? 'Mark as uncompleted'
                        : 'Mark as completed',
                  ),
                  onPressed: () {
                    _toggleActive(index);
                  }),
            );
          }),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new todo',
        child: const Icon(Icons.add),
        onPressed: () {
          _promptNewTodo();
        },
      ),
    );
  }

  void _promptNewTodo() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var newTodoController = TextEditingController();
          return AlertDialog(
            scrollable: true,
            title: const Text('Add new todo'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: newTodoController,
                      decoration: const InputDecoration(
                        labelText: 'New todo',
                        icon: Icon(Icons.checklist_rounded),
                      ),
                      maxLines: null,
                      autofocus: true,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () {
                    _addTodoAndReturn(newTodoController.text, context);
                  })
            ],
          );
        });
  }

  /// Delete todo at index i
  void _delete(int i) {
    setState(() {
      _deleted.add(_todos[i]);
      _todos.removeAt(i);
    });
  }

  /// Un-delete todo at index i of _deleted
  void _restore(int i) {
    setState(() {
      _todos.add(_deleted[i]);
      _deleted.removeAt(i);
    });
  }

  /// Toggle status of todo at index i between completed and active.
  void _toggleActive(int i) {
    setState(() {
      _todos[i].toggleStatus();
    });
  }

  void _addTodoAndReturn(String newTodo, BuildContext context) {
    _addTodo(newTodo);
    Navigator.of(context).pop();
  }

  void _addTodo(String todo) {
    setState(() {
      _todos.add(TodoEntry(todo));
    });
  }
}

class TodoEntry {
  String content;
  bool isCompleted;

  TodoEntry(this.content, [this.isCompleted = false]);

  void toggleStatus() {
    isCompleted = !isCompleted;
  }
}
