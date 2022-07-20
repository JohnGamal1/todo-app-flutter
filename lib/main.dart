import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({Key? key}) : super(key: key);

  static final _defaultLightColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.orange,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.orange,
    brightness: Brightness.dark,
  );
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'todo',
        theme: ThemeData(
          toggleableActiveColor:
              lightColorScheme?.primary ?? _defaultLightColorScheme.primary,
          scaffoldBackgroundColor: lightColorScheme?.background,
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          toggleableActiveColor:
              darkColorScheme?.primary ?? _defaultLightColorScheme.primary,
          scaffoldBackgroundColor: darkColorScheme?.background,
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        home: const ToDoDashboard(),
      );
    });
  }
}

class ToDoDashboard extends StatefulWidget {
  const ToDoDashboard({Key? key}) : super(key: key);

  @override
  State<ToDoDashboard> createState() => _ToDoDashboardState();
}

class _ToDoDashboardState extends State<ToDoDashboard> {
  final TextEditingController _todoController = TextEditingController();
  late final TextFormField _addNewTodo = TextFormField(
    controller: _todoController,
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.add),
      border: InputBorder.none,
      hintText: 'New item',
    ),
    onFieldSubmitted: (a) async {
      await addTodo(todo: _todoController.text).whenComplete(() {
        _todoController.clear();
        setState(() {});
      });
    },
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      body: FutureBuilder<Widget>(
          future: todos(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            }
            return const Center(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
    );
  }

  Future<Widget> todos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getStringList('todo') ?? prefs.setStringList('todo', <String>[]);
    List<String> todo = prefs.getStringList('todo')!;
    if (todo.isNotEmpty) {
      return ListView.builder(
          itemCount: todo.length + 1,
          itemBuilder: (context, index) {
            todo.add("");
            while (todo.last == todo[index]) {
              return _addNewTodo;
            }
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(removeRegExp(todo[index])),
              secondary: IconButton(
                  onPressed: () => deleteTodo(todo: todo[index])
                      .whenComplete(() => setState(() {})),
                  icon: const Icon(Icons.delete)),
              value: todo[index].contains("-true"),
              onChanged: (value) {
                updateTodo(todo: todo[index], checked: value!)
                    .whenComplete(() => setState(() {}));
              },
            );
          });
    } else {
      return _addNewTodo;
    }
  }

  Future<void> addTodo({required String todo}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> todoList = prefs.getStringList('todo')!;
    todoList.add(addTodoExp(todo));
    prefs.setStringList("todo", todoList);
  }

  Future<void> deleteTodo({required String todo}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> todoList = prefs.getStringList('todo')!;
    todoList.remove(todo);
    prefs.setStringList('todo', todoList);
  }

  Future<void> updateTodo({required String todo, required bool checked}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> todoList = prefs.getStringList('todo')!;
    todoList[todoList.indexWhere((element) => element == todo)] =
        "${removeRegExp(todo)}-$checked";
    prefs.setStringList("todo", todoList);
  }

  String addTodoExp(String todo) {
    return "$todo-false";
  }

  String removeRegExp(String todo) {
    // ignore: unnecessary_string_escapes
    return todo.replaceFirst(RegExp("\-false|\-true"), "");
  }
}
