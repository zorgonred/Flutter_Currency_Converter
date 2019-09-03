import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?format=json&key=80f27c39";

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar_buy;
  double euro_buy;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dollar_buy).toStringAsFixed(2);
    euroController.text = (real / euro_buy).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dollar_buy).toStringAsFixed(2);
    euroController.text =
        (dolar * this.dollar_buy / euro_buy).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro_buy).toStringAsFixed(2);
    dolarController.text =
        (euro * this.euro_buy / dollar_buy).toStringAsFixed(2);
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(
      title: Text("Converter"),
      backgroundColor: Colors.amber,
      centerTitle: true,
      ),
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                        "Loading...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                          "Error :(",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center,
                        ));
                  } else {
                    dollar_buy =
                    snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro_buy =
                    snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.monetization_on,
                                size: 150.0, color: Colors.amber),
                            buildTextField(
                                "Reals", "R\$", realController, _realChanged),
                            Divider(),
                            buildTextField(
                                "Dollars", "US\$", dolarController,
                                _dolarChanged),
                            Divider(),
                            buildTextField(
                                "Euros", "€", euroController, _euroChanged),
                          ],
                        ));
                  }
              }
            }),
      );
    }
  }



Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
