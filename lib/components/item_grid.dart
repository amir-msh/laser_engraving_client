import 'package:flutter/material.dart';

class ItemGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;

  const ItemGrid({
    required this.crossAxisCount,
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // child: Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   crossAxisAlignment: CrossAxisAlignment.stretch,
    //   mainAxisSize: MainAxisSize.max,
    //   children: [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       mainAxisSize: MainAxisSize.max,
    //       children: const [
    //         Expanded(child: OptionCard()),
    //         Expanded(child: OptionCard()),
    //       ],
    //     ),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       mainAxisSize: MainAxisSize.max,
    //       children: const [
    //         Expanded(child: OptionCard()),
    //         Expanded(child: OptionCard()),
    //       ],
    //     ),
    //   ],
    // ),
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        (children.length + (children.length % crossAxisCount)) ~/
            crossAxisCount,
        (rowIndex) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: List.generate(
            (children.length ~/ crossAxisCount) == rowIndex
                ? crossAxisCount - 1
                : crossAxisCount,
            (columnIndex) => Expanded(
              child: Container(
                height: 50,
                width: 50,
                color: Colors.amber,
                margin: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: Text(((columnIndex + 1) * (rowIndex + 1)).toString()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
