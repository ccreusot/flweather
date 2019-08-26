import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _searchPending = false;
  Weather _currentWeather = null;

  void requestWeatherFor(String location) async {
    var response = await http
        .get("https://www.prevision-meteo.ch/services/json/$location");
    var bodyResponse = json.decode(response.body);

    setState(() {
      _searchPending = false;
      _currentWeather = Weather(
          bodyResponse['city_info']['name'],
          bodyResponse['current_condition']['tmp'],
          bodyResponse['current_condition']['hour'],
          bodyResponse['current_condition']['icon_big']);
    });
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
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: "Enter your city"),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        requestWeatherFor(value);
                        setState(() {
                          _searchPending = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    if (_searchPending)
                      Center(child: CircularProgressIndicator())
                    else if (_currentWeather != null)
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    _currentWeather.hour,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w200,
                                    )),
                                Text(
                                  _currentWeather.name,
                                  style: TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w300,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "${_currentWeather.currentTemperature}˚",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Image.network(_currentWeather.icon, width: 42, height: 42)
                              ],
                            ),
                          )
                        ],
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Weather {
  final String name;
  final int currentTemperature;
  final String hour;
  final String icon;

  Weather(this.name, this.currentTemperature, this.hour, this.icon);
}
