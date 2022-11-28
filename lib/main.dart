import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MaterialApp(
    home: PronadiUredaje(),
  ));
}

class PronadiUredaje extends StatelessWidget {
  const PronadiUredaje({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bluetooth uređaji'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((rezultat) => ListTile(
                          title: Text(rezultat.device.name == ""
                              ? "Nema naziva "
                              : rezultat.device.name),
                          subtitle: Text(rezultat.device.id.toString()),
                          onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                rezultat.device.connect();
                                return SpojiSeNaUredaj(device: rezultat.device);
                              })).then(
                                  (value) => {rezultat.device.disconnect()})))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBlue.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => FlutterBlue.instance.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () => FlutterBlue.instance
                      .startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}

class SpojiSeNaUredaj extends StatefulWidget {
  final BluetoothDevice device;

  const SpojiSeNaUredaj({Key? key, required this.device}) : super(key: key);

  @override
  State<SpojiSeNaUredaj> createState() => _SpojiSeNaUredajState();
}

class _SpojiSeNaUredajState extends State<SpojiSeNaUredaj> {
  String tekst = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text(widget.device.name == ""
                ? widget.device.id.toString()
                : widget.device.name),
            actions: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white // Text Color
                      ),
                  child: Text("Prikaži servis"),
                  onPressed: () {
                    dohvatServisa(widget.device).then((String vrijednost) {
                      setState(() {
                        tekst = vrijednost;
                      });
                    });
                  })
            ],
          ),
          body: Center(
            child: Text(
              tekst,
              style: TextStyle(fontSize: 30),
            ),
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                upisiUServis(widget.device).then((String vrijednost) {
                  setState(() {
                    tekst = vrijednost;
                  });
                });
              }),
    ));
  }
}

Future<String> dohvatServisa(BluetoothDevice device) async {
  var rezultat;
  List<BluetoothService> servisi = await device.discoverServices();
  var karakterisitke = servisi[2].characteristics;
  for (BluetoothCharacteristic k in karakterisitke) {
    List<int> vrijednost = await k.read();
    rezultat = utf8.decode(vrijednost);
    if (rezultat == "0") {
      return "Led svijetlo je ugašeno";
    } else {
      return "Led svijetlo je upaljeno";
    }
  }
  return "";
}

Future<String> upisiUServis(BluetoothDevice device) async {
  var rezultat;
  List<BluetoothService> servisi = await device.discoverServices();
  var karakteristike = servisi[2].characteristics;
  for (BluetoothCharacteristic k in karakteristike) {
    List<int> vrijednost = await k.read();
    rezultat = utf8.decode(vrijednost);
    if (rezultat == "0") {
      await k.write([49]);
      return "Led svijetlo je upaljeno";
    } else {
      await k.write([48]);
      return "Led svijetlo je ugašeno";
    }
  }
  return "";
}
