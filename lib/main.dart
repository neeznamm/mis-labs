import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  initializeDateFormatting('mk', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Термини за колоквиуми и испити',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<SubjectData> subjects;

  @override
  void initState() {
    super.initState();
    subjects = List.generate(4, (index) {
      return SubjectData(
        name: 'Предмет $index',
        year: 'I',
        dateTime: DateTime.now(),
      );
    });
  }

  void onChangesSaved(SubjectData updatedData, int? index) {
    setState(() {
      if (index != null) {
        subjects[index] = updatedData;
      } else {
        subjects.add(updatedData);
      }
    });
  }

  void _showAddSubjectModal(BuildContext context) {
    String editedName = '';
    String editedYear = '';
    DateTime editedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Додај предмет'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: editedName,
                    decoration: const InputDecoration(labelText: 'Име'),
                    onChanged: (value) {
                      setState(() {
                        editedName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    initialValue: editedYear,
                    decoration: const InputDecoration(labelText: 'Година'),
                    onChanged: (value) {
                      setState(() {
                        editedYear = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8.0),
                        Text(
                          'Датум: ${DateFormat('d MMMM (EEEE)', 'mk').format(editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8.0),
                        Text(
                          'Време: ${DateFormat('HH:mm', 'mk').format(editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: editedDateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (picked != null && picked != editedDateTime) {
                              setState(() {
                                editedDateTime = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  editedDateTime.hour,
                                  editedDateTime.minute,
                                );
                              });
                            }
                          },
                          child: const Text('Смени датум', style: TextStyle(fontSize: 12.0)),
                        ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(editedDateTime),
                              );

                              if (picked != null) {
                                setState(() {
                                  editedDateTime = DateTime(
                                    editedDateTime.year,
                                    editedDateTime.month,
                                    editedDateTime.day,
                                    picked.hour,
                                    picked.minute,
                                  );
                                });
                              }
                            },
                            child: const Text('Смени време', style: TextStyle(fontSize: 12.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Назад'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editedName.isNotEmpty && editedYear.isNotEmpty) {
                      onChangesSaved(
                        SubjectData(
                          name: editedName,
                          year: editedYear,
                          dateTime: editedDateTime,
                        ),
                        null,
                      );

                      Navigator.pop(context);
                    } else {
                    }
                  },
                  child: const Text('Зачувај'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Термини за колоквиуми и испити'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddSubjectModal(context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: subjects.length,
        itemBuilder: (BuildContext context, int index) {
          return SubjectWidget(
            subjectData: subjects[index],
            onChangesSaved: onChangesSaved,
            index: index,
          );
        },
      ),
    );
  }
}

class SubjectData {
  String name;
  String year;
  DateTime dateTime;

  SubjectData({
    required this.name,
    required this.year,
    required this.dateTime,
  });
}

class SubjectWidget extends StatefulWidget {
  final SubjectData subjectData;
  final Function(SubjectData, int?) onChangesSaved;
  final int index;

  const SubjectWidget({
    Key? key,
    required this.subjectData,
    required this.onChangesSaved,
    required this.index,
  }) : super(key: key);

  @override
  State<SubjectWidget> createState() => _SubjectWidgetState();
}

class _SubjectWidgetState extends State<SubjectWidget> {
  late String _editedName;
  late String _editedYear;
  late DateTime _editedDateTime;

  @override
  void initState() {
    super.initState();
    _editedName = widget.subjectData.name;
    _editedYear = widget.subjectData.year;
    _editedDateTime = widget.subjectData.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showEditModal(context);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.subjectData.name,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' ${widget.subjectData.year} година',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
            Text(
              DateFormat('d MMMM (EEEE) HH:mm', 'mk').format(
                  widget.subjectData.dateTime),
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context) {
    _editedName = widget.subjectData.name;
    _editedYear = widget.subjectData.year;
    _editedDateTime = widget.subjectData.dateTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Измени предмет'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: _editedName,
                    decoration: const InputDecoration(labelText: 'Име'),
                    onChanged: (value) {
                      setState(() {
                        _editedName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    initialValue: _editedYear,
                    decoration: const InputDecoration(labelText: 'Година'),
                    onChanged: (value) {
                      setState(() {
                        _editedYear = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8.0),
                        Text(
                          'Датум: ${DateFormat('d MMMM (EEEE)', 'mk').format(_editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8.0),
                        Text(
                          'Време: ${DateFormat('HH:mm', 'mk').format(_editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _editedDateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (picked != null && picked != _editedDateTime) {
                              setState(() {
                                _editedDateTime = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  _editedDateTime.hour,
                                  _editedDateTime.minute,
                                );
                              });
                            }
                          },
                          child: const Text('Смени датум', style: TextStyle(fontSize: 12.0)),
                        ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_editedDateTime),
                              );

                              if (picked != null) {
                                setState(() {
                                  _editedDateTime = DateTime(
                                    _editedDateTime.year,
                                    _editedDateTime.month,
                                    _editedDateTime.day,
                                    picked.hour,
                                    picked.minute,
                                  );
                                });
                              }
                            },
                            child: const Text('Смени време', style: TextStyle(fontSize: 12.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Назад'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onChangesSaved(
                      SubjectData(
                        name: _editedName,
                        year: _editedYear,
                        dateTime: _editedDateTime,
                      ),
                      widget.index,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Зачувај'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
