import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:laser_engraving_client/image_processing/image_processing.dart';
import 'package:laser_engraving_client/utils/functions.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageConversionTestPage extends StatefulWidget {
  const ImageConversionTestPage({Key? key}) : super(key: key);

  @override
  State<ImageConversionTestPage> createState() =>
      _ImageConversionTestPageState();
}

class _ImageConversionTestPageState extends State<ImageConversionTestPage> {
  Uint8List? bleBytes;
  final int btImgWidth = 32;
  late final int imgPixels = btImgWidth * btImgWidth;
  late final int btPacketSize = imgPixels ~/ 8;
  String imageText = '';
  io.File? picFile;
  Uint8List? editedImageBytes;
  BluetoothConnection? _btConnection;
  Stream<Uint8List>? _btInputBroadcastStream;

  Widget imageFrameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    return Center(
      child: child,
    );
    // return Center(
    //   child: Container(
    //     constraints: const BoxConstraints.tightFor(),
    //     padding: const EdgeInsets.all(0),
    //     decoration: BoxDecoration(
    //       border: Border.all(
    //         color: Colors.orange,
    //         width: 5,
    //       ),
    //     ),
    //     child: child,
    //   ),
    // );
  }

  Future<void> initBluetooth() async {
    if (!(await FlutterBluetoothSerial.instance.requestEnable() ?? false)) {
      return;
    }
    if ((await Permission.bluetoothScan.request()) !=
            PermissionStatus.granted ||
        (await Permission.bluetooth.request()) != PermissionStatus.granted ||
        (await Permission.bluetoothConnect.request()) !=
            PermissionStatus.granted) {
      return;
    }

    try {
      await FlutterBluetoothSerial.instance.cancelDiscovery();
      await Future.delayed(const Duration(milliseconds: 1000));
      FlutterBluetoothSerial.instance.state.then(
        (value) async {
          final devices = Set<BluetoothDevice>.from(
            await FlutterBluetoothSerial.instance.getBondedDevices(),
          );

          return FlutterBluetoothSerial.instance.startDiscovery().listen(
            (res) => devices.add(res.device),
            onError: (e, s) {
              log('Flutter bluetooth listening error', error: e);
            },
            onDone: () async {
              log('Scanning Done');
              for (var device in devices) {
                if (device.address == '00:18:E5:03:7D:0E') {
                  log(
                    device.isConnected.toString(),
                    name: 'device.isConnected?',
                  );
                  _btConnection = await BluetoothConnection.toAddress(
                    device.address,
                  );
                  await Future.delayed(const Duration(milliseconds: 500));
                  _btInputBroadcastStream =
                      _btConnection!.input?.asBroadcastStream();
                  log('Bluetooth connected to ${device.name}: ${device.address}');
                  setState(() {});
                  break;
                }
              }
            },
          );
        },
      );
    } catch (exception) {
      log('Cannot connect, exception occured');
    }
  }

  Future<bool> waitForString(
    Stream<Uint8List> cnStream, {
    required String waitFor,
    Duration? timeout = const Duration(seconds: 10),
  }) async {
    assert(cnStream.isBroadcast, "Please pass a broadcast stream");

    String sumStr = '';
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
          sumStr += pkt;
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
    // if (subs == null) return false;

    return completer.future.then((res) async {
      log(sumStr, name: 'sumStr : ');
      timeoutTimer?.cancel();
      await subs.cancel();
      return res;
    });
  }

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _btConnection?.close();
    _btConnection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                if (picFile != null)
                  Expanded(
                    child: Image.file(
                      picFile!,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      frameBuilder: imageFrameBuilder,
                    ),
                  ),
                if (editedImageBytes != null)
                  Expanded(
                    child: Image.memory(
                      editedImageBytes!,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      frameBuilder: imageFrameBuilder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (imageText.isNotEmpty) Text(imageText),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                allowCompression: false,
                type: FileType.image,
                dialogTitle: 'Please choose an image',
                allowMultiple: false,
              );
              if (result != null && result.files.single.path != null) {
                setState(() {
                  picFile = io.File(result.files.single.path!);
                });
              }
            },
            child: const Text('Select an image'),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () async {
              if (picFile == null) return;
              final sw = Stopwatch()..start();
              // editedImageBytes = Uint8List.fromList(
              //   img.encodeBmp(
              //     await convertToEdgeDetected(
              //       await convertFileToEditableImage(picFile!),
              //     ),
              //   ),
              // );
              final rawImage =
                  // img.invert(
                  await convertToRidgeDetected(
                await convertFileToEditableImage(picFile!),
                // ),
              );
              editedImageBytes = Uint8List.fromList(
                img.encodeBmp(
                  img.copyResize(
                    rawImage,
                    width: btImgWidth,
                    height: btImgWidth,
                    // interpolation: img.Interpolation.linear,
                  ),
                ),
              );
              sw.stop();
              imageText = '${sw.elapsedMilliseconds} ms';
              setState(() {});

              final printPic = img.copyResize(
                rawImage,
                width: btImgWidth,
                height: btImgWidth,
              );
              log('printPic Res : ${printPic.width} * ${printPic.height}');
              log('Converting image to valid bytes :');
              bleBytes = Uint8List(imgPixels ~/ 8);
              int bitIndex = 0;
              for (int y = 0; y < btImgWidth; y++) {
                for (int x = 0; x < btImgWidth; x++) {
                  if (printPic.getPixel(x, y) != 0xff000000) {
                    bleBytes![bitIndex ~/ 8] = setBitInByte(
                      bleBytes![bitIndex ~/ 8],
                      7 - (bitIndex % 8),
                      true,
                    );
                  }
                  bitIndex++;
                }
              }
              // log('_________________');
              // log(
              // log('bleBytes : ${bleBytes!.toList().toString()}');
              //   'converted bleBytes :' +
              //       Uint8List.fromList(
              //         String.fromCharCodes(bleBytes!.toList()).codeUnits,
              //       ).toString(),
              // );
            },
            child: const Text('Process the current image'),
          ),
          const SizedBox(height: 6),
          Offstage(
            offstage: _btConnection == null && bleBytes == null,
            child: ElevatedButton(
              onPressed: () async {
                if (picFile == null) return;

                log('Sending request');

                _btConnection!.output.add(
                  Uint8List.fromList(
                    '#mode:rb($btImgWidth,$btPacketSize)\r\n'.codeUnits,
                  ),
                );
                log('request sent');

                final packetsNumber = imgPixels ~/ btPacketSize;
                log(bleBytes!.length.toString());
                for (int pktNum = 0; pktNum < packetsNumber; pktNum++) {
                  final done = await waitForString(
                    _btInputBroadcastStream!,
                    waitFor: '#done\r',
                    timeout: Duration(milliseconds: btPacketSize * 8 * 500),
                  );
                  if (done) {
                    log('response received (success)');
                    final currentPkg = bleBytes!.getRange(
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
                setState(() {});
              },
              child: const Text('Send image to the device'),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
