import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dias que comprei',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dias que comprei'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<DateTime> _comprou = [];
  List<DateTime> _ncomprou = [];
  CalendarFormat _format = CalendarFormat.month;
  Future<bool> _getPrefsData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    List<String> _listaDiasCompra =
        _prefs.getStringList('listaDiasCompra') ?? [];
    List<String> _listaDiasNCompra =
        _prefs.getStringList('listaDiasNCompra') ?? [];
    _comprou =
        _listaDiasCompra.map((String dia) => DateTime.parse(dia)).toList();
    _ncomprou =
        _listaDiasNCompra.map((String dia) => DateTime.parse(dia)).toList();
    return true;
  }

  Future<void> _setPrefsData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setStringList(
        'listaDiasCompra',
        _comprou.map((DateTime dia) {
          return dia.toString();
        }).toList());
    _prefs.setStringList(
        'listaDiasNCompra',
        _ncomprou.map((DateTime dia) {
          return dia.toString();
        }).toList());
  }

  _getEvent(day) {
    final events = <String>[];
    if (_comprou.contains(day)) {
      events.add('Comprou');
    } else if (_ncomprou.contains(day)) {
      events.add('Não Comprou');
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getPrefsData(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                  ),
                  body: Center(
                    child: TableCalendar(
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mês',
                        CalendarFormat.week: 'Semana',
                        CalendarFormat.twoWeeks: 'Duas semanas',
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _format = format;
                        });
                      },
                      calendarFormat: _format,
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.contains('Comprou')) {
                            return Container(
                              child: const Text(
                                'events.first',
                                style: TextStyle(
                                    color: Color.fromARGB(1, 1, 1, 0)),
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            );
                          } else if (events.contains('Não Comprou')) {
                            return Container(
                              child: const Text(
                                'events.first',
                                style: TextStyle(
                                    color: Color.fromARGB(1, 1, 1, 0)),
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            );
                          }
                        },
                      ),
                      locale: 'pt_BR',
                      calendarStyle: CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        outsideDaysVisible: false,
                      ),
                      firstDay: DateTime.utc(2022, 01, 01),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      eventLoader: (day) {
                        return _getEvent(day);
                      },
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: () async {
                          setState(() {
                            if (!_comprou.contains(_focusedDay)) {
                              _comprou.add(_focusedDay);
                            }
                            _ncomprou.remove(_focusedDay);
                          });
                          await _setPrefsData();
                        },
                        tooltip: 'Comprei',
                        child: const Icon(
                          Icons.shopping_cart,
                        ),
                        backgroundColor: Colors.green,
                      ),
                      const SizedBox(width: 50, height: 100),
                      FloatingActionButton(
                        onPressed: () async {
                          setState(() {
                            _comprou.remove(_focusedDay);
                            _ncomprou.remove(_focusedDay);
                          });
                          await _setPrefsData();
                        },
                        backgroundColor: Colors.blue,
                        tooltip: 'Limpar dia',
                        child: const Icon(
                          Icons.clear,
                        ),
                      ),
                      const SizedBox(width: 50, height: 100),
                      FloatingActionButton(
                        onPressed: () async {
                          setState(() {
                            _comprou.remove(_focusedDay);
                            if (!_ncomprou.contains(_focusedDay)) {
                              _ncomprou.add(_focusedDay);
                            }
                          });
                          await _setPrefsData();
                        },
                        backgroundColor: Colors.red,
                        tooltip: 'Não comprei',
                        child: const Icon(
                          Icons.remove_shopping_cart,
                        ),
                      ),
                    ],
                  ),
                );
        });
  }
}
