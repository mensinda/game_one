import 'package:flutter/material.dart';
import 'package:game_one/bluetooth.dart';
import 'package:scoped_model/scoped_model.dart';

class Bluetooth extends StatefulWidget {
  _BluetoothState createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GameBluetooth>(
      builder: (context, child, model) => Container(
        child: RefreshIndicator(
          onRefresh: () => model.scan(),
          child:  ListView(
              children: _buildList(model),
            )
          )
        )
    );
  }

  List<Widget> _buildList(GameBluetooth model) {
    if (model.state == GameBLEState.SEARCHING) {
      return <Widget>[
        Container(
          color: Colors.greenAccent,
          child: ListTile(
            title: Text('Scanning...'),
          )
        )
      ];
    }

    if (model.state == GameBLEState.OFF) {
      return <Widget>[
        Container(
          color: Colors.redAccent,
          child: ListTile(
            title: Text('Bluetooth is disabled on this device'),
          )
        )
      ];
    }

    if (model.devices.isEmpty) {
      return <Widget>[
        Container(
          color: Colors.black12,
          child: ListTile(
            title: Text('No devices found - swipe down to scan again'),
          )
        )
      ];
    }

    List<Widget> tiles = <Widget>[];

    for (GameBluetoothDev i in model.devices) {
      tiles.add(
        Card(
          child: ListTile(
            title:       Text(i.name),
            subtitle:    Text(i.id),
            onTap:       () => model.connect(i),
            onLongPress: () => model.disconnect(),
            leading: Icon(
              i.icon,
              size: 48,
            ),
          ),
        )
      );
    }

    return tiles;
  }
}

