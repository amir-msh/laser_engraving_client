import 'package:equatable/equatable.dart';

abstract class BluetoothComState extends Equatable {
  const BluetoothComState();
}

class BluetoothComInitialState extends BluetoothComState {
  @override
  List<Object?> get props => [];
}

class BluetoothComRequestingPermissionState extends BluetoothComState {
  @override
  List<Object?> get props => [];
}

class BluetoothComDiscoveryState extends BluetoothComState {
  @override
  List<Object?> get props => [];
}

class BluetoothComConnectedState extends BluetoothComState {
  @override
  List<Object?> get props => [];
}

class BluetoothComSendingDataState extends BluetoothComState {
  final double progress;
  const BluetoothComSendingDataState({
    required this.progress,
  });
  @override
  List<Object?> get props => [];
}

class BluetoothComErrorState extends BluetoothComState {
  final String errorText;
  const BluetoothComErrorState(this.errorText);
  @override
  List<Object?> get props => [errorText];
}
