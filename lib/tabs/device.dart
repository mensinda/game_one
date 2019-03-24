import 'package:card_settings/card_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:game_one/bluetooth.dart';
import 'package:scoped_model/scoped_model.dart';

class CardSettingsMyInfo extends StatelessWidget {
  final String label;
  final String initialValue;
  final Icon   icon;

  CardSettingsMyInfo({Key key,
    bool autovalidate: false,
    this.initialValue = '<N/A>',
    this.label = 'Label',
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardSettingsField(
      label: label,
      visible: true,
      icon: icon,
      content: Text(initialValue, style: TextStyle(fontSize: 16.0)),
    );
  }
}

class DeviceSettings extends StatefulWidget {
  DeviceSettings({Key key}) : super(key: key);

  _DeviceSettingsState createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GameBluetooth>(
      builder: (context, child, model) => CardSettings(
        children: _buildItems(model)
      ),
    );
  }

  List<Widget> _buildItems(GameBluetooth model) {
    return (model.conDev?.state ?? BluetoothDeviceState.disconnected) == BluetoothDeviceState.connected ? _buildSettings(model) :_buildError();
  }

  List<Widget> _buildSettings(GameBluetooth model) {
    List<Widget> widgets = <Widget>[];

    widgets.add(CardSettingsHeader(label: 'Device information'));
    widgets.add(CardSettingsMyInfo(label: 'Name',        initialValue: model.conDev.name));
    widgets.add(CardSettingsMyInfo(label: 'ID',          initialValue: model.conDev.id));
    widgets.add(CardSettingsMyInfo(label: 'Motors',      initialValue: '${model.conDev.numMotors}'));
    widgets.add(CardSettingsMyInfo(label: 'Updates / s', initialValue: '${model.conDev.updates}'));
    widgets.add(CardSettingsMyInfo(label: 'Initialized', initialValue: '${model.conDev.isInitialized}'));
    widgets.add(CardSettingsMyInfo(label: 'Is TECO',     initialValue: '${model.conDev.isTECO}'));
    widgets.add(CardSettingsHeader(label: 'Motor test'));
    widgets.add(CardSettingsButton(label: 'Test all', onPressed: () async {
      print('TEST');
      model.conDev.motors = [model.conDev.startupMotorVal, model.conDev.startupMotorVal, model.conDev.startupMotorVal, model.conDev.startupMotorVal];
      await Future.delayed(Duration(seconds: 2));
      model.conDev.motors = [0, 0, 0, 0];
    }));

    widgets.add(CardSettingsButton(label: 'Left', onPressed: () async {
      print('TEST LEFT');
      model.conDev.left = model.conDev.startupMotorVal;
      await Future.delayed(Duration(seconds: 2));
      model.conDev.left = 0;
    }));

    widgets.add(CardSettingsButton(label: 'Right', onPressed: () async {
      print('TEST RIGHT');
      model.conDev.right = model.conDev.startupMotorVal;
      await Future.delayed(Duration(seconds: 2));
      model.conDev.right = 0;
    }));

    widgets.add(CardSettingsButton(label: 'Front', onPressed: () async {
      print('TEST FRONT');
      model.conDev.front = model.conDev.startupMotorVal;
      await Future.delayed(Duration(seconds: 2));
      model.conDev.front = 0;
    }));

    widgets.add(CardSettingsButton(label: 'Back', onPressed: () async {
      print('TEST BACK');
      model.conDev.back = model.conDev.startupMotorVal;
      await Future.delayed(Duration(seconds: 2));
      model.conDev.back = 0;
    }));

    widgets.add(CardSettingsHeader(label: 'Mapping'));
    widgets.add(CardSettingsInt(label: 'Left  index', initialValue: model.conDev.getMapping(MotorLoc.LEFT),  onChanged: (val) => model.conDev.setMapping(MotorLoc.LEFT,  val)));
    widgets.add(CardSettingsInt(label: 'Right index', initialValue: model.conDev.getMapping(MotorLoc.RIGHT), onChanged: (val) => model.conDev.setMapping(MotorLoc.RIGHT, val)));
    widgets.add(CardSettingsInt(label: 'Front index', initialValue: model.conDev.getMapping(MotorLoc.FRONT), onChanged: (val) => model.conDev.setMapping(MotorLoc.FRONT, val)));
    widgets.add(CardSettingsInt(label: 'Back  index', initialValue: model.conDev.getMapping(MotorLoc.BACK),  onChanged: (val) => model.conDev.setMapping(MotorLoc.BACK,  val)));
    widgets.add(CardSettingsHeader(label: 'etc'));
    widgets.add(CardSettingsInt(label: 'Updates per second', initialValue: model.conDev.updateFrequency, onChanged: (val) => model.conDev.updateFrequency = val));
    widgets.add(CardSettingsInt(label: 'Min motor value',    initialValue: model.conDev.minMotorVal,     onChanged: (val) => model.conDev.minMotorVal     = val));
    widgets.add(CardSettingsInt(label: 'Start motor value',  initialValue: model.conDev.startupMotorVal, onChanged: (val) => model.conDev.startupMotorVal = val));

    return widgets;
  }

  List<Widget> _buildError() {
    return <Widget>[CardSettingsHeader(
        color: Colors.redAccent,
        label: 'No device is currently connected',
      )
    ];
  }
}

