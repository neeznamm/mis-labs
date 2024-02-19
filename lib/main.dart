import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NotificationService.dart';

void main() {
  NotificationService().initNotification();
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('en', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam schedule',
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
  bool isGridView = false;
  bool isCalendarView = true;
  bool isGroupedView = false;
  DateTime _focusedDay = DateTime.now();
  List<SubjectData> subjects = [];

  late Map<DateTime, List<SubjectData>> subjectsByDate;
  late Map<String, List<SubjectData>> subjectsByLocation;
  bool subjectsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSubjectsFromPrefs().then((loadedSubjects) {
      if (loadedSubjects != null) {
        subjects = loadedSubjects;
        subjectsByDate = _groupSubjectsByDate(subjects);
        subjectsByLocation = _groupSubjectsByLocation(subjects);
        setState(() {
          subjectsLoaded = true;
        });
      }
    });
  }


  Future<List<SubjectData>?> _loadSubjectsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = prefs.getString('subjects');

    if (subjectsJson != null) {
      Iterable subjectsIterable = jsonDecode(subjectsJson);
      return List<SubjectData>.from(subjectsIterable.map((subjectJson) {
        return SubjectData.fromJson(subjectJson);
      }));
    }

    return null;
  }


  Future<void> _saveSubjectsToPrefs(List<SubjectData> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = jsonEncode(subjects);
    prefs.setString('subjects', subjectsJson);
  }

  void setGridView() {
    setState(() {
      isGridView = true;
      isCalendarView = false;
      isGroupedView = false;
    });
  }

  void setCalendarView() {
    setState(() {
      isGridView = false;
      isCalendarView = true;
      isGroupedView = false;
    });
  }

  void setLocationView() {
    setState(() {
      isGridView = false;
      isCalendarView = false;
      isGroupedView = true;
    });
  }

  void onChangesSaved(SubjectData updatedData, int? index) async {
    if (index != null) {
      if (updatedData.name.isEmpty) {
        subjects.removeAt(index);
      } else {
        subjects[index] = updatedData;
      }
    } else {
      subjects.add(updatedData);
    }

    subjectsByDate = _groupSubjectsByDate(subjects);
    subjectsByLocation = _groupSubjectsByLocation(subjects);
    await _saveSubjectsToPrefs(subjects);
    _scheduleNotificationsForExams(subjects);
    setState(() {});
  }

  void _scheduleNotificationsForExams(List<SubjectData> exams) async {
    for (var exam in exams) {
      final DateTime sevenDaysBefore = exam.dateTime.subtract(const Duration(days: 7));
      final DateTime oneDayBefore = exam.dateTime.subtract(const Duration(days: 1));
      final DateTime sixHoursBefore = exam.dateTime.subtract(const Duration(hours: 6));

      var notificationTitle = "";
      DateTime minTime;

      if (DateTime.now().isBefore(sevenDaysBefore)) {
        minTime = sevenDaysBefore;
        notificationTitle = "7 days before exam";
      } else if (DateTime.now().isBefore(oneDayBefore)) {
        minTime = oneDayBefore;
        notificationTitle = "1 day before exam";
      } else if (DateTime.now().isBefore(sixHoursBefore)) {
        minTime = sixHoursBefore;
        notificationTitle = "6 hours before exam";
      } else {

        continue;
      }

      _scheduleNotification(exam, minTime, notificationTitle);
    }
  }



  void _scheduleNotification(SubjectData exam, DateTime notificationTime, String title) async {
    final int notificationId = exam.name.hashCode;

    await NotificationService().showNotification(
      id: notificationId,
      title: title,
      body: '${exam.name} on ${DateFormat('d MMMM (EEEE) HH:mm').format(exam.dateTime)}',
    );
  }


  Map<DateTime, List<SubjectData>> _groupSubjectsByDate(List<SubjectData> subjects) {
    Map<DateTime, List<SubjectData>> groupedSubjects = {};

    for (var subject in subjects) {
      DateTime dateTime = subject.dateTime;


      DateTime date = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (groupedSubjects.containsKey(date)) {
        groupedSubjects[date]!.add(subject);
      } else {
        groupedSubjects[date] = [subject];
      }
    }

    return groupedSubjects;
  }


  Map<String, List<SubjectData>> _groupSubjectsByLocation(List<SubjectData> subjects) {
    Map<String, List<SubjectData>> groupedSubjects = {};

    for (var subject in subjects) {
      String location = subject.location;

      if (groupedSubjects.containsKey(location)) {
        groupedSubjects[location]!.add(subject);
      } else {
        groupedSubjects[location] = [subject];
      }
    }

    return groupedSubjects;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {

    List<SubjectData>? examsOnSelectedDay = subjectsByDate[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];

    if (examsOnSelectedDay != null && examsOnSelectedDay.isNotEmpty) {
      _showExamsOnSelectedDay(context, examsOnSelectedDay);
    }
  }


  void _showExamsOnSelectedDay(BuildContext context, List<SubjectData> examsOnSelectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exams on ${examsOnSelectedDay.first.dateTime.day}-${examsOnSelectedDay.first.dateTime.month}-${examsOnSelectedDay.first.dateTime.year}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examsOnSelectedDay
                .map((exam) => Text(
              '${exam.name} @ ${DateFormat('HH:mm').format(exam.dateTime)}',
              style: const TextStyle(fontSize: 14.0),
            ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSubjectModal(BuildContext context) {
    String editedName = '';
    String editedYear = SubjectData.validYears.first;
    DateTime editedDateTime = DateTime.now();
    String editedLocation = '';
    bool isSaveButtonEnabled = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add subject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: editedName,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      setState(() {
                        editedName = value;
                        isSaveButtonEnabled = value.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                    ),
                    value: editedYear,
                    items: SubjectData.validYears.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          editedYear = value;
                        });
                      }
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
                          'Date: ${DateFormat('d MMMM (EEEE)').format(editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: editedDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (picked != editedDateTime) {
                        setState(() {
                          editedDateTime = DateTime(
                            picked!.year,
                            picked.month,
                            picked.day,
                            editedDateTime.hour,
                            editedDateTime.minute,
                          );
                        });
                      }
                    },
                    child: const Text('Edit date', style: TextStyle(fontSize: 12.0)),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8.0),
                        Text(
                          'Time: ${DateFormat('HH:mm').format(editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
                      child: const Text('Edit time', style: TextStyle(fontSize: 12.0)),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: (value) {
                      setState(() {
                        editedLocation = value;
                      });
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaveButtonEnabled ? () {
                    if (editedName.isNotEmpty && editedYear.isNotEmpty) {
                      onChangesSaved(
                        SubjectData(
                          name: editedName,
                          year: editedYear,
                          dateTime: editedDateTime,
                          location: editedLocation,
                        ),
                        null,
                      );

                      Navigator.pop(context);
                    } else {

                    }
                  } : null,
                  child: const Text('Save'),
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
        title: const Text('Exam schedule'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddSubjectModal(context);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: setGridView,
            icon: Icon(isGridView ? Icons.grid_on : Icons.grid_on_outlined),
          ),
          IconButton(
            onPressed: setCalendarView,
            icon: Icon(isCalendarView ? Icons.calendar_today : Icons.calendar_today_outlined),
          ),
          IconButton(
            onPressed: setLocationView,
            icon: Icon(isGroupedView ? Icons.location_on : Icons.location_on_outlined),
          ),
        ],
      ),
      body: subjectsLoaded
          ? subjects.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Yay! You don\'t have any exams scheduled.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            Image.asset('assets/images/cat.png', width: 300.0, height: 300.0, fit: BoxFit.contain),
          ],
        ),
      )
          : isGridView
          ? GridView.builder(
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
      ) : isGroupedView ? _buildGroupedView()
          : TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime(2000),
        lastDay: DateTime(2101),
        calendarFormat: CalendarFormat.month,
        onFormatChanged: (format) {

        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        onDaySelected: _onDaySelected,
        eventLoader: (date) {
          return subjectsByDate[DateTime(date.year, date.month, date.day)] ?? [];
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.green,
          ),
          outsideDaysVisible: false,
        ),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


  Widget _buildGroupedView() {
    return ListView(
      children: subjectsByLocation.keys.map((location) {
        return ExpansionTile(
          title: Text(location),
          children: subjectsByLocation[location]!.map((subject) {
            return ListTile(
              title: Text(subject.name),
              subtitle: Text(
                DateFormat('d MMMM (EEEE) HH:mm').format(subject.dateTime),
              ),

            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class SubjectData {
  String name;
  String year;
  DateTime dateTime;
  String location;

  static const List<String> validYears = ['I', 'II', 'III', 'IV'];

  SubjectData({
    required this.name,
    required this.year,
    required this.dateTime,
    required this.location,
  });


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': year,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
    };
  }


  factory SubjectData.fromJson(Map<String, dynamic> json) {
    return SubjectData(
      name: json['name'],
      year: json['year'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
    );
  }
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
  late String _editedLocation;

  @override
  void initState() {
    super.initState();
    _editedName = widget.subjectData.name;
    _editedDateTime = widget.subjectData.dateTime;
    _editedLocation = widget.subjectData.location;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showEditModal(context);
      },
      onLongPress: () {
        _showDeleteDialog(context);
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
              ' ${widget.subjectData.year}',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
            Text(
              DateFormat('d MMMM (EEEE) HH:mm').format(widget.subjectData.dateTime),
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
            Text(
              'Location: ${widget.subjectData.location}',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: const Text('Are you sure you want to delete this subject?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onChangesSaved(SubjectData(name: '', year: '', dateTime: DateTime.now(), location: ''), widget.index);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditModal(BuildContext context) {
    _editedName = widget.subjectData.name;
    _editedYear = widget.subjectData.year;
    _editedDateTime = widget.subjectData.dateTime;
    _editedLocation = widget.subjectData.location;
    bool isSaveButtonEnabled = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit subject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: _editedName,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      setState(() {
                        _editedName = value;
                        isSaveButtonEnabled = value.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                    ),
                    value: _editedYear,
                    items: SubjectData.validYears.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _editedYear = value;
                        });
                      }
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
                          'Date: ${DateFormat('d MMMM (EEEE)').format(_editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
                    child: const Text('Edit date', style: TextStyle(fontSize: 12.0)),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 8.0),
                        Text(
                          'Time: ${DateFormat('HH:mm').format(_editedDateTime)}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Flexible(
                    child:
                    ElevatedButton(
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
                      child: const Text('Edit time', style: TextStyle(fontSize: 12.0)),
                    )
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    initialValue: _editedLocation,
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: (value) {
                      setState(() {
                        _editedLocation = value;
                      });
                    },
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaveButtonEnabled
                      ? () {
                    widget.onChangesSaved(
                      SubjectData(
                        name: _editedName,
                        year: _editedYear,
                        dateTime: _editedDateTime,
                        location: _editedLocation,
                      ),
                      widget.index,
                    );
                    Navigator.pop(context);
                  }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
