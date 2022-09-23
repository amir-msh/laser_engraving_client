import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHelper {
  static const bluetoothPermissions = [
    Permission.bluetoothScan,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ];

  BluetoothHelper() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    FlutterBluetoothSerial.instance.state;
  }

  Stream<BluetoothState> get onStateChanged =>
      FlutterBluetoothSerial.instance.onStateChanged();

  Future<bool> requestEnable() async {
    await FlutterBluetoothSerial.instance.state;
    return await FlutterBluetoothSerial.instance.requestEnable() ?? false;
  }

  Future<bool> requestDisable() async {
    await FlutterBluetoothSerial.instance.state;
    return await FlutterBluetoothSerial.instance.requestDisable() ?? false;
  }

  Future<bool> requestPermissions() async {
    for (var permission in bluetoothPermissions) {
      if (await permission.request() != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<bool> hasPermissions() async {
    for (var permission in bluetoothPermissions) {
      if (!await permission.isGranted) return false;
    }
    return true;
  }

  Future<BluetoothHelperConnection> connectTo(
    String deviceAddress, [
    String? devicePassword,
  ]) async {
    if (!await requestPermissions()) {
      throw Exception('Permission Denied!');
    }

    final btSerial = await FlutterBluetoothSerial.instance.state;

    if (btSerial == BluetoothState.ERROR ||
        btSerial == BluetoothState.STATE_BLE_TURNING_OFF ||
        btSerial == BluetoothState.STATE_OFF ||
        btSerial == BluetoothState.UNKNOWN) {
      throw Exception("Bluetooth isn't on!");
    }
    final deviceCompleter = Completer<BluetoothDevice?>();

    await FlutterBluetoothSerial.instance.cancelDiscovery();

    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    if (devicePassword != null) {
      FlutterBluetoothSerial.instance.setPairingRequestHandler(
        (request) {
          return Future.value(devicePassword);
          // if (request.address == deviceAddress) {}
          // return Future.value(null);
        },
      );
    }

    final bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    bondedDevices.removeWhere(
      (device) => device.address != deviceAddress,
    );
    // && device.isConnected,

    if (bondedDevices.isNotEmpty) {
      deviceCompleter.complete(bondedDevices.last);
    } else {
      FlutterBluetoothSerial.instance.startDiscovery().listen(
        (res) {
          log('${res.device.name}:${res.device.address} FOUND!');
          if (res.device.address == deviceAddress) {
            FlutterBluetoothSerial.instance.cancelDiscovery().then(
                  (value) => deviceCompleter.complete(res.device),
                );
          }
        },
        onError: (e, s) {
          deviceCompleter.complete(null);
          log('Flutter bluetooth listening error', error: e);
        },
        onDone: () async {},
      );
    }

    final device = await deviceCompleter.future.timeout(
      const Duration(seconds: 20),
    );

    if (device != null) {
      FlutterBluetoothSerial.instance.setPairingRequestHandler(null);

      return BluetoothHelperConnection(
        await BluetoothConnection.toAddress(deviceAddress),
      );
    } else {
      throw Exception("The device isn't available!");
    }
  }
}

class BluetoothHelperConnection {
  final BluetoothConnection _connection;
  Stream<Uint8List> input;

  BluetoothHelperConnection(
    final BluetoothConnection connection,
  )   : _connection = connection,
        assert(connection.input != null),
        assert(!connection.input!.isBroadcast),
        input = connection.input!.asBroadcastStream();

  StreamSink<Uint8List> get output => _connection.output;
  bool get isConnected => _connection.isConnected;

  Future<void> finish() => _connection.finish();
  Future<void> close() => _connection.close();

  @override
  String toString() => _connection.toString();

  void dispose() => {_connection.dispose()};
}
