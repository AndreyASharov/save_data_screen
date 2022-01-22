import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const FilesDemoScreen());
}

class FilesDemoScreen extends StatelessWidget {
  const FilesDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Данные в файле',
      home: FlutterDemo(
        title: '',
        storage: CounterStorage(),
      ),
    );
  }
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;
    return file.writeAsString('$counter');
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({Key? key, required this.storage, required this.title})
      : super(key: key);
  final CounterStorage storage;
  final String title;

  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counterFile = 0;
  int _counterShare = 0;
  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counterFile = value;
        _loadCounterShare();
      });
    });
  }

  void _loadCounterShare() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterShare = (prefs.getInt('counter') ?? 0);
    });
  }

  void _incrementCounterShare() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _counterShare = (pref.getInt('counter') ?? 0) + 1;
      pref.setInt('counter', _counterShare);
    });
  }

  Future<File> _incrementCounterFile() {
    setState(() {
      _counterFile++;
    });
    return widget.storage.writeCounter(_counterFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              'Данные в файле',
              style: TextStyle(fontSize: 30, color: Color(0x99000000)),
            ),
            const SizedBox(height: 30),
            Text(
                'Кнопка нажата $_counterFile раз${
                    (_counterFile % 10 != 2 && _counterFile % 10 != 3 && _counterFile % 10 != 4) ? '' : 'а'}.'),
            const SizedBox(height: 30),
            ElevatedButton(
                child: const Text("в файл"), onPressed: _incrementCounterFile),
            const SizedBox(height: 100),
            const Text(
              'Данные на устройстве',
              style: TextStyle(fontSize: 30, color: Color(0x99000000)),
            ),
            const SizedBox(height: 30),
            Text(
                'Кнопка нажата $_counterShare раз${
                    (_counterShare % 10 != 2 && _counterShare % 10 != 3 && _counterShare % 10 != 4) ? ' ' : 'а'}.'),
            const SizedBox(height: 30),
            ElevatedButton(
                child: const Text("на устройстве"),
                onPressed: _incrementCounterShare),
          ],
        ),
      ),
    ));
  }
}
