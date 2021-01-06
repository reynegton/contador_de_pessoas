import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<int> _maxPeople;
  TextEditingController _controller;
  int _people = 0;
  String _infotext = "Pode Entrar.";

  Future<void> _setMaxPeople(int max) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _maxPeople = prefs.setInt("maxPeople", max).then((bool success) {
        _changePeople(0, max);
        return max;
      });
    });
  }

  void _changePeople(int aux, int maxPeople) {
    setState(() {
      _people += aux;
      if (_people >= maxPeople)
        _infotext = "Lotado!";
      else
        _infotext = "Pode Entrar.";

      if (_people < 0) _people = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _maxPeople = _prefs.then((SharedPreferences prefs) {
      var max = (prefs.getInt('maxPeople') ?? 10);
      _controller.text = max.toString();
      return max;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.only(top: 50, left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                decoration: new InputDecoration(
                  labelText: "Máximo de pessoas.",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _controller,
                onSubmitted: (String value) async {
                  _setMaxPeople(int.parse(value));
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Contador de pessoas',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            "images/restaurant.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          FutureBuilder<int>(
            future: _maxPeople,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                default:
                  if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pessoas: $_people',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                  child: Text(
                                    '+1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 40,
                                    ),
                                  ),
                                  onPressed: () {
                                    _changePeople(1, snapshot.data);
                                    debugPrint("+1");
                                  }),
                              FlatButton(
                                child: Text(
                                  '-1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 40,
                                  ),
                                ),
                                onPressed: () {
                                  _changePeople(-1, snapshot.data);
                                  debugPrint("-1");
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _infotext,
                          style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    );
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}
