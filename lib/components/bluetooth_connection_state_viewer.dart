import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laser_engraving_client/components/searching_indicator.dart';
import 'package:laser_engraving_client/riverpod/bluetooth/bluetooth_notifier.dart';
import 'package:laser_engraving_client/riverpod/bluetooth/bluetooth_state.dart';

class BluetoothConnectionStateViewer extends ConsumerWidget {
  const BluetoothConnectionStateViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bluetoothComProvider);

    late final Widget icon;

    if (state is BluetoothComRequestingPermissionState) {
      icon = Container(
        padding: const EdgeInsets.all(3.75),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.perm_scan_wifi_outlined,
          key: const Key('BluetoothComRequestingPermissionState()'),
          color: Theme.of(context).errorColor,
        ),
      );
    } else if (state is BluetoothComDiscoveryState) {
      icon = const SearchingIndicator(
        key: Key('BluetoothComDiscoveryState()'),
      );
    } else if (state is BluetoothComSendingDataState) {
      if (state.progress == 1.0) {
        icon = const Icon(
          Icons.done,
          key: Key('BluetoothComSendingDataState(progress:1.0)'),
          color: Colors.white,
        );
      } else if (state.progress == 0.0) {
        icon = const Icon(
          Icons.bluetooth_connected_rounded,
          key: Key('BluetoothComSendingDataState(progress:0.0)'),
          color: Colors.white,
        );
      } else {
        icon = Transform.scale(
          key: Key('BluetoothComSendingDataState(progress:${state.progress})'),
          scale: 0.75,
          child: CircularProgressIndicator.adaptive(
            value: state.progress,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(
                      0.2,
                    ),
          ),
        );
      }
    } else if (state is BluetoothComErrorState) {
      icon = Icon(
        Icons.error_outline,
        key: const Key('BluetoothComErrorState()'),
        color: Theme.of(context).errorColor,
      );
    } else {
      icon = Transform.scale(
        key: Key('Other states'),
        scale: 0.75,
        child: const CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 960),
      reverseDuration: const Duration(milliseconds: 960),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.66,
            end: 1,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: Center(
              child: child,
            ),
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: icon,
    );
  }
}
