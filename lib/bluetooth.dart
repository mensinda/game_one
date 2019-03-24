import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';

const String BLE_NUM_MOTORS = '713D0001-503E-4C75-BA94-3148F18D941E';
const String BLE_UPDATES    = '713D0002-503E-4C75-BA94-3148F18D941E';
const String BLE_CONTROL    = '713D0003-503E-4C75-BA94-3148F18D941E';

typedef void GameBLEDevUpdatedCB();

enum MotorLoc {
  FRONT,
  BACK,
  LEFT,
  RIGHT,
}

class GameBluetoothDev {
  final BluetoothDevice dev;
  final String          name;

  List<BluetoothService> services;

  GameBLEDevUpdatedCB onUpdated = () {};

  bool                 _startedInitializatuion = false;
  bool                 _isInitialized          = false;
  BluetoothDeviceState _state                  = BluetoothDeviceState.disconnected;
  int                  _numMotors              = 0;
  int                  _updatesPerSecond       = 2;

  int updateFrequency = 10;
  int minMotorVal     = 0x70;
  int startupMotorVal = 0xcc;

  StreamSubscription<void> _updateLoopFuture;
  BluetoothCharacteristic  _motorControl;
  List<int>                _current  = [0, 0, 0, 0];
  Map<MotorLoc, int>       _motorMap = {MotorLoc.FRONT: 3, MotorLoc.BACK: 1, MotorLoc.LEFT: 2, MotorLoc.RIGHT: 0};

  set motors(List<int> values) {
    _current = values.map((i) => max(0, min(i, 0xFF))).take(4).toList();
  }

  void setMotor(int motor, int value) {
    motor = max(0, min(motor, 3));
    value = max(0, min(value, 0xFF));

    List<int> newL =  _current;
    newL[motor] = value;
    motors = newL;
  }

  set left(int val)  => setMotor(_motorMap[MotorLoc.LEFT],  val);
  set right(int val) => setMotor(_motorMap[MotorLoc.RIGHT], val);
  set front(int val) => setMotor(_motorMap[MotorLoc.FRONT], val);
  set back(int val)  => setMotor(_motorMap[MotorLoc.BACK],  val);

  int  getMapping(MotorLoc m) => _motorMap[m];
  void setMapping(MotorLoc m, int index) => _motorMap[m] = max(0, min(index ?? 0, 3));

  Future<void> _updateLoop() async {
    while (true) {
      await Future.delayed(Duration(milliseconds: (1000 / (updateFrequency ?? 2)).floor()));
      if (_motorControl == null) { continue; }
      print('BLE: UPDATE $_current');
      await dev.writeCharacteristic(_motorControl, _current);
    }
  }

  Future<void> _onConnect() async {
    print('BLE: CONNECTED "$name" $id');
    if (_startedInitializatuion || _isInitialized) {
      return;
    }
    _startedInitializatuion = true;

    print('BLE: INITIALIZING...');

    services = await dev.discoverServices();
    for (BluetoothService i in services) {
      for (BluetoothCharacteristic j in i.characteristics) {
        if (j.uuid == Guid(BLE_NUM_MOTORS)) {
          _numMotors = (await dev.readCharacteristic(j))[0];
        }

        if (j.uuid == Guid(BLE_UPDATES)) {
          _updatesPerSecond = (await dev.readCharacteristic(j))[0];
        }

        if (j.uuid == Guid(BLE_CONTROL)) {
          _motorControl = j;
        }
      }
    }

    _startedInitializatuion = false;
    _isInitialized          = true;
    this.motors = [startupMotorVal, startupMotorVal, startupMotorVal, startupMotorVal];
    _updateLoopFuture = _updateLoop().asStream().listen((s) {});
    print('BLE: INITIALIZED -- Motors: $_numMotors; Updates: $_updatesPerSecond');
    onUpdated();
  }

  Future<void> _onDisconnect() async {
    print('BLE: DISCONNECTED');
    _isInitialized    = false;
    _numMotors        = 0;
    _updatesPerSecond = 0;
    _updateLoopFuture?.cancel();
    onUpdated();
  }

  set state(BluetoothDeviceState s) {
    _state = s;
    switch (_state) {
      case BluetoothDeviceState.connected: _onConnect(); break;
      case BluetoothDeviceState.disconnected: _onDisconnect(); break;
      default: break;
    }
  }

  String               get id            => dev.id.id;
  BluetoothDeviceState get state         => _state;
  bool                 get isInitialized => _isInitialized;
  bool                 get isConnected   => _state == BluetoothDeviceState.connected;
  bool                 get isTECO        => _motorControl != null;
  int                  get numMotors     => _numMotors;
  int                  get updates       => _updatesPerSecond;

  IconData get icon {
    switch (this._state) {
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

  bool _isScanning = false;
  var _connection; // Device connection stream

  GameBLEState get state => _state;

  void _setState(BluetoothState s) {
    switch (s) {
      case BluetoothState.on:  _state = GameBLEState.ON; break;
      default: _state = GameBLEState.OFF; break;
    }

    if (_state == GameBLEState.ON && _isScanning == true) {
      _state = GameBLEState.SEARCHING;
    }
    if (_state == GameBLEState.ON && conDev?.state == BluetoothDeviceState.connected) {
      _state = GameBLEState.CONNECTED;
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

    print('BLE: SCANNING...');

    _isScanning = true;
    _setState(await ble.state);

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
      dev.onUpdated = () => notifyListeners();
      devices.add(dev);
    }

    _isScanning = false;
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
    _connection = ble.connect(dev.dev).listen((BluetoothDeviceState s) async {
      dev.state = s;
      _setState(await ble.state);
      notifyListeners();
    });
    conDev = dev;
  }

  Future<void> disconnect() async {
    await _connection?.cancel();
    conDev?.state = BluetoothDeviceState.disconnected;
    conDev = null;
    _setState(await ble.state);
    notifyListeners();
  }

  factory GameBluetooth() => _singleton;
  GameBluetooth._internal() {
    ble.state.then((BluetoothState s) => _setState(s));
    ble.onStateChanged().forEach((BluetoothState s) => _setState(s));
  }
}

