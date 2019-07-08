import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=b3a0ada4";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double _dolar;
  double _euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    dolarController.text = (real / _dolar).toStringAsFixed(2);
    euroController.text = (real / _euro).toStringAsFixed(2);
    print(text);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this._dolar).toStringAsFixed(2);
    euroController.text = (dolar * this._dolar / _euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this._euro).toStringAsFixed(2);
    dolarController.text = (euro * this._euro / _dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  Future<Map> getData() async {
    http.Response response = await http.get(request);
    return (json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$Conversor de moedas\$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center),
                );
              } else {
                _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTexField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTexField(
                            "Dólares", "U\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTexField(
                            "Euros", "€", euroController, _euroChanged)
                      ],
                    ),
                    padding: EdgeInsets.all(10.0));
              }
          }
        },
      ),
    );
  }
}

Widget buildTexField(String label, String prefix,
    TextEditingController controller, Function handleChange) {
  return (TextField(
    controller: controller,
    onChanged: handleChange,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.amber,
        ),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
  ));
}
