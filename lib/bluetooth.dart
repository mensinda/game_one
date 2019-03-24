import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';

class GameBluetoothDev {
  final BluetoothDevice dev;
  final String          name;

  BluetoothDeviceState state = BluetoothDeviceState.disconnected;

  bool get isConnected => state == BluetoothDeviceState.connected;

  String get id => dev.id.id;

  IconData get icon {
    switch (this.state) {
      case BluetoothDeviceState.disconnected:  return Icons.bluetooth;
      case BluetoothDeviceState.connected:     return Icons.bluetooth_connected;
      case BluetoothDeviceState.connecting:    return Icons.bluetooth_searching;
      default: return Icons.bluetooth_disabled;
    }
  }

  GameBluetoothDev({@required this.dev, @required this.name});
}

enum GameBLEState {
  ON,
  OFF,
  SEARCHING,
  CONNECTED
}

typedef void GameBLEStateChanged(GameBLEState state);

class GameBluetooth extends Model {
  static final GameBluetooth _singleton = GameBluetooth._internal();
  final        FlutterBlue   ble        = FlutterBlue.instance;

  List<GameBluetoothDev> devices = [];
  GameBluetoothDev       conDev;
  GameBLEState           _state = GameBLEState.OFF;
  GameBLEStateChanged    onStateChanged = (s) {};

  var _connection; // Device connection stream

  GameBLEState get state => _state;

  void _setState(BluetoothState s) {
    switch (s) {
      case BluetoothState.on:  _state = GameBLEState.ON; break;
      default: _state = GameBLEState.OFF; break;
    }
    notifyListeners();
  }

  Icon get bluetoothIcon {
    switch (this.state) {
      case GameBLEState.ON:        return Icon(Icons.bluetooth);
      case GameBLEState.CONNECTED: return Icon(Icons.bluetooth_connected);
      case GameBLEState.SEARCHING: return Icon(Icons.bluetooth_searching);
      case GameBLEState.OFF:
      default: return Icon(Icons.bluetooth_disabled);
    }
  }

  Future<List<GameBluetoothDev>> scan() async {
    if (_state != GameBLEState.ON && _state != GameBLEState.CONNECTED) {
      return [];
    }

    _state = GameBLEState.SEARCHING;
    notifyListeners();

    await disconnect();
    devices.clear();
    conDev = null;

    await for (ScanResult res in ble.scan(timeout: Duration(seconds: 5))) {
      String name = String.fromCharCodes(res.advertisementData.localName.runes.takeWhile((code) => code != 0)).trim();
      String id   = res.device.id.id;
      if (devices.any((d) => d.id == id)) {
        continue;
      }

      GameBluetoothDev dev = GameBluetoothDev(dev: res.device, name: name);
      devices.add(dev);
    }

    _setState(await ble.state);
    return devices;
  }

  Future<void> connect(GameBluetoothDev dev) async {
    if (dev.state != BluetoothDeviceState.disconnected) {
      return;
    }
    await disconnect();
    dev.state = BluetoothDeviceState.connecting;
    notifyListeners();
    _connection = ble.connect(dev.dev).listen((BluetoothDeviceState s) {
      dev.state = s;
      notifyListeners();
    });
    conDev = dev;
  }

  Future<void> disconnect() async {
    await _connection?.cancel();
    conDev?.state = BluetoothDeviceState.disconnected;
    conDev = null;
    notifyListeners();
  }

  factory GameBluetooth() => _singleton;
  GameBluetooth._internal() {
    ble.state.then((BluetoothState s) => _setState(s));
    ble.onStateChanged().forEach((BluetoothState s) => _setState(s));
  }
}