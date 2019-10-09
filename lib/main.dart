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
        primarySwatch: Colors.green,
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
  List<String> _cities = List();
  List<Weather> _weathers = List();
  TextEditingController _editingController = TextEditingController();

  void requestWeatherFor(String location) async {
    var response = await http
        .get("https://www.prevision-meteo.ch/services/json/$location");
    var bodyResponse = json.decode(response.body);

    if (bodyResponse["errors"] == null) {
      setState(() {
        final weatherToAdd = Weather(
            bodyResponse['city_info']['name'],
            bodyResponse['current_condition']['tmp'],
            bodyResponse['current_condition']['hour'],
            bodyResponse['current_condition']['icon_big']);
        _searchPending = false;
        _cities.add(location);
        _weathers.firstWhere((weather) {
          return weather.name.compareTo(weatherToAdd.name) == 0;
        }, orElse: () {
          _weathers.add(weatherToAdd);
          return null;
        });
      });
    } else {
      setState(() {
        _searchPending = false;
      });
    }
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          FocusScope.of(context).unfocus();
          requestWeatherFor(_editingController.text);
          setState(() {
            _searchPending = true;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                      controller: _editingController,
                      decoration: InputDecoration(hintText: "Enter your city"),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              if (_searchPending)
                Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_weathers.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                    if (index >= _weathers.length) {
                      return null;
                    }
                    var currentWeather = _weathers[index];
                    return WeatherItemWidget(weather: currentWeather);
                  }),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherItemWidget extends StatelessWidget {
  Weather _weather;

  WeatherItemWidget({weather}) : _weather = weather;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_weather.hour,
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                        )),
                    Text(
                      _weather.name,
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
                      "${_weather.currentTemperature}˚",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Image.network(_weather.icon, width: 42, height: 42)
                  ],
                ),
              )
            ],
          )
        ],
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
