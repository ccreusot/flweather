import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _searchLocation = "";

  void requestWeatherFor(String location) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("test showing location: $location"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(hintText: "Enter your city"),
                  textInputAction: TextInputAction.search,
                  onChanged: (String value) => _searchLocation = value,
                  onEditingComplete: () {
                    requestWeatherFor(_searchLocation);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
