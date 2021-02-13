import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    supportedLocales: [const Locale('pt', 'BR')],
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  TextEditingController _taskController = TextEditingController();
  List _toDoList = [];
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  String timeValue = "";
  TimeOfDay selectedTime = TimeOfDay.now();
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;
  bool tap = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["date"] = dateFormat.format(date);
      date = DateTime.now();
      newToDo["time"] = timeValue;
      timeValue = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
        _saveData();
      });
    });
  }

  Future<Null> selectDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2001),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  Future<Null> selectTimePicker(BuildContext context) async {
    final TimeOfDay timePicked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (timePicked != null && timePicked != selectedTime)
      setState(() {
        selectedTime = timePicked;
        timeValue = timePicked.format(context);
      });
  }

  createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Nova Tarefa",
              style: TextStyle(
                fontFamily: "DarkerGrotesque",
                fontSize: 25.0,
              ),
            ),
            content: Container(
              height: 180.0,
              child: Column(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _toDoController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Insira sua Tarefa";
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: Icon(Icons.calendar_today),
                          iconSize: 40.0,
                          color: Colors.lightBlue,
                          onPressed: () {
                            selectDatePicker(context);
                          }),
                      IconButton(
                          icon: Icon(Icons.access_time),
                          iconSize: 40.0,
                          color: Colors.lightBlue,
                          onPressed: () {
                            selectTimePicker(context);
                          }),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      fontFamily: "DarkerGrotesque",
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _toDoController.text = "";
                    timeValue = "";
                    date = DateTime.now();
                  }),
              MaterialButton(
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      fontFamily: "DarkerGrotesque",
                      fontSize: 20.0,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _addToDo();
                      Navigator.of(context).pop();
                    }
                  }),
            ],
          );
        });
  }

  taskNumber() {
    String taskNumberText = "";

    if (_toDoList.length == 0) {
      taskNumberText = "Parabéns você concluiu suas tarefas!";
    } else if (_toDoList.length == 1) {
      taskNumberText = "${_toDoList.length} tarefa";
    } else {
      taskNumberText = "${_toDoList.length} tarefas";
    }
    return taskNumberText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                children: <Widget>[
                  Stack(children: [
                    Image.asset(                     
                      "images/wallpaper.jpg",
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),

                        ),
                      ),                  
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 130, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: Colors.white,
                            size: 40.0,
                          ),
                          Text(
                            "Minhas Tarefas",
                            style: TextStyle(
                                fontFamily: "DarkerGrotesque",
                                fontSize: 35.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            taskNumber(),
                            style: TextStyle(
                                fontFamily: "DarkerGrotesque",
                                fontSize: 17.0,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.fromLTRB(50, 30, 50, 30),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0))),
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: _toDoList.length,
                      itemBuilder: buildItem),
                )),
            //)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        elevation: 10,
        onPressed: () {
          createAlertDialog(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: GestureDetector(
        onTap: () => {
          setState(() {
            _toDoList[index]["ok"] = true;
            _saveData();
          }),
        },
        onDoubleTap: () => {
          setState(() {
            _toDoList[index]["ok"] = false;
            _saveData();
          })
        },
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor:
                  _toDoList[index]["ok"] ? Colors.white : Colors.white,
              foregroundColor:
                  _toDoList[index]["ok"] ? Colors.green : Colors.pink,
              child: Icon(
                _toDoList[index]["ok"] ? Icons.check_circle : Icons.access_time,
                size: 30.0,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(_toDoList[index]["title"],
                      style: TextStyle(
                          fontFamily: "DarkerGrotesque",
                          fontWeight: FontWeight.bold,
                          fontSize: 23.0)),
                ),
                Row(
                  children: [
                    Text(_toDoList[index]["date"],
                        style: TextStyle(
                            fontFamily: "DarkerGrotesque",
                            fontSize: 16.0,
                            color: Colors.grey[700])),
                    SizedBox(
                      width: 15,
                    ),
                    Text(_toDoList[index]["time"],
                        style: TextStyle(
                            fontFamily: "DarkerGrotesque",
                            fontSize: 16.0,
                            color: Colors.grey[700])),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.grey[300],
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 1,
                ),
              ],
            ),
            //_toDoList[index]["ok"],
          ],
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.jason");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
