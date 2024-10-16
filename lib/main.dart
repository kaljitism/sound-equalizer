import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(theme: ThemeData.dark(), home: const HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> getNameFromServer() {
    return Future.delayed(
      const Duration(seconds: 4),
      () => 'Narendra',
    );
  }

  late Future<String> name;

  @override
  void initState() {
    super.initState();
    name = getNameFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () {},
            child: const Text('Get Data'),
          ),
          const SizedBox(height: 10),
          // here we will print the name
          buildFutureWidget(),
        ],
      ),
    );
  }

  FutureBuilder<String> buildFutureWidget() {
    return FutureBuilder(
      future: name,
      builder: (context, snapshot) {
        bool checkNone = snapshot.connectionState == ConnectionState.none;
        bool checkWaiting = snapshot.connectionState == ConnectionState.waiting;
        bool checkActive = snapshot.connectionState == ConnectionState.active;
        bool checkDone = snapshot.connectionState == ConnectionState.done;
        bool checkError = snapshot.hasError;

        if (checkNone) onNone();
        if (checkWaiting) onWaiting();
        if (checkActive) onActive();
        if (checkDone) onDone(snapshot.data!);
        if (checkError) onError(snapshot.error.toString());
        return ErrorWidget('');
      },
    );
  }

  ErrorWidget onNone() => WidgetGetter.onNone();

  CircularProgressIndicator onWaiting() => WidgetGetter.onWaiting();

  CircularProgressIndicator onActive() => WidgetGetter.onActive();

  Text onDone(String data) => WidgetGetter.onDone(data);

  ErrorWidget onError(String error) => WidgetGetter.onError(error);
}

abstract class WidgetGetter {
  static ErrorWidget onNone() {
    return ErrorWidget(Exception());
  }

  static CircularProgressIndicator onWaiting() {
    return const CircularProgressIndicator();
  }

  static CircularProgressIndicator onActive() {
    return const CircularProgressIndicator();
  }

  static Text onDone(String data) {
    return Text(data);
  }

  static ErrorWidget onError(String error) {
    return ErrorWidget(Exception(error));
  }
}
