import 'package:flutter/material.dart';

class LabeledDuration extends StatelessWidget {
  final String label;
  final String durationText;
  LabeledDuration({
    Key? key,
    required this.label,
    String? durationText,
    Duration? duration,
  })  : assert(
          (duration != null && durationText == null) ||
              (duration == null && durationText != null),
        ),
        durationText = durationText ?? durationToReadable(duration!),
        super(key: key);

  static String durationToReadable(Duration duration) {
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    String hours = '';
    if (duration.inHours > 0) {
      hours = ":${duration.inHours.toString().padLeft(2, '0')}";
    }
    return '$hours$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const Spacer(),
        Text(
          durationText,
        ),
      ],
    );
  }
}
