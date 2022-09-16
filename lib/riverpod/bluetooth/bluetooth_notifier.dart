import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laser_engraving_client/bluetooth_helper/bluetooth_helper.dart';
import 'package:laser_engraving_client/riverpod/bluetooth/bluetooth_state.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/utils/functions.dart';

final bluetoothComProvider =
    StateNotifierProvider<BluetoothComNotifier, BluetoothComState>(
  (_) => BluetoothComNotifier(),
);

class BluetoothComNotifier extends StateNotifier<BluetoothComState> {
  StreamSubscription<BluetoothState>? _onStateChangedSubscription;
  BluetoothHelperConnection? _btConnection;
  static const btAddress = '00:18:E5:03:7D:0E';
  static const btPassword = '1234';
  final btHelper = BluetoothHelper();

  BluetoothComNotifier() : super(BluetoothComInitialState()) {
    _onStateChangedSubscription =
        FlutterBluetoothSerial.instance.onStateChanged().listen(
      (event) {
        if (event == BluetoothState.STATE_TURNING_OFF) {
          Future(() {
            state = const BluetoothComErrorState('Bluetooth turned off!');
          });
        } else if (event == BluetoothState.ERROR) {
          Future(
            () {
              state = const BluetoothComErrorState('Bluetooth error!');
            },
          );
        }
      },
    );
  }

  Future<void> initialize() async {
    if (!await requestPermissions()) return;

    try {
      state = BluetoothComDiscoveryState();
      _btConnection = await btHelper.connectTo(btAddress);

      state = BluetoothComConnectedState();
    } catch (e) {
      state = BluetoothComErrorState(e.toString());
    }
  }

  Future<void> sendImage(img.Image image) async {
    assert(image.width == image.height);
    assert(image.width <= 512);

    final imgWidth = image.width;
    final imgPixels = imgWidth * imgWidth;
    final btPacketSize = imgPixels ~/ 8;
    //imgPixels ~/ 8;
    final bleBytes = Uint8List(imgPixels ~/ 8);

    log('Image Res : $imgWidth * $imgWidth');
    log('Converting image to valid bytes ...');

    int bitIndex = 0;

    for (int y = 0; y < imgWidth; y++) {
      for (int x = 0; x < imgWidth; x++) {
        if (image.getPixel(x, y) != 0xff000000) {
          bleBytes[bitIndex ~/ 8] = setBitInByte(
            bleBytes[bitIndex ~/ 8],
            7 - (bitIndex % 8),
            true,
          );
        }
        bitIndex++;
      }
    }
    log('Image convertion finished');

    log('Sending request');

    _btConnection!.output.add(
      Uint8List.fromList(
        '#mode:rb($imgWidth,$btPacketSize)\r\n'.codeUnits,
      ),
    );
    log('request sent');

    final packetsLength = imgPixels ~/ btPacketSize;
    log(bleBytes.length.toString());
    // state = const BluetoothComSendingDataState(progress: 0);

    for (int pktNum = 0; pktNum < packetsLength; pktNum++) {
      final done = await waitForString(
        _btConnection!.input,
        waitFor: '#done\r',
        timeout: Duration(milliseconds: btPacketSize * 8 * 500),
      );
      await Future.delayed(const Duration(milliseconds: 750));
      state = BluetoothComSendingDataState(
        progress: pktNum / math.max(1, packetsLength - 1),
      );
      if (done) {
        log('response received (success)');
        final currentPkg = bleBytes.getRange(
          pktNum * btPacketSize,
          pktNum * btPacketSize + btPacketSize,
        );
        _btConnection!.output.add(
          Uint8List.fromList([
            ...'#data:'.codeUnits,
            ...currentPkg.toList(),
            ...'\r\n'.codeUnits,
          ]),
        );
        log(currentPkg.toString());
        log('data sent');
      } else {
        log('response received (fail)');
        break;
      }
    }
  }

  Future<bool> requestPermissions() async {
    if (!await btHelper.hasPermissions()) {
      state = BluetoothComRequestingPermissionState();
      if (!await btHelper.requestPermissions()) {
        state = const BluetoothComErrorState("Permission denied");
        return false;
      }
    }
    return true;
  }

  Future<bool> waitForString(
    Stream<Uint8List> cnStream, {
    required String waitFor,
    Duration? timeout = const Duration(seconds: 10),
  }) async {
    assert(cnStream.isBroadcast, "Please pass a broadcast stream");

    const terminatorChar = '\n';
    final buffer = StringBuffer();
    final completer = Completer<bool>();
    Timer? timeoutTimer;
    if (timeout != null) {
      timeoutTimer = Timer(
        timeout,
        () => completer.complete(false),
      );
    }

    final subs = cnStream.listen(
      (data) {
        final str = utf8.decode(data);
        final endIndex = str.indexOf(terminatorChar);
        if (endIndex >= 0) {
          buffer.write(str.substring(0, endIndex));
          final pkt = buffer.toString();

          log(pkt, name: 'waitForString() [Serial Packet] : ');
          if (pkt.contains(waitFor)) {
            completer.complete(true);
          } else {
            buffer
              ..clear()
              ..write(str.substring(endIndex, str.length));
          }
        } else {
          buffer.write(str);
        }
      },
      onDone: () => completer.complete(false),
      onError: (e, s) => completer.complete(false),
      cancelOnError: false,
    );

    return completer.future.then((res) async {
      timeoutTimer?.cancel();
      await subs.cancel();
      return res;
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _btConnection?.close().then((value) => _btConnection?.dispose());
    _onStateChangedSubscription?.cancel();
    super.dispose();
  }
}
