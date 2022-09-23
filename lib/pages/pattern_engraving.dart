import 'package:flutter/material.dart';
import 'package:laser_engraving_client/components/pattern_card.dart';

class PatternEngravingPage extends StatefulWidget {
  const PatternEngravingPage({Key? key}) : super(key: key);

  @override
  State<PatternEngravingPage> createState() => _PatternEngravingPageState();
}

class _PatternEngravingPageState extends State<PatternEngravingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patterns'),
      ),
      body: ListView.builder(
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        padding: const EdgeInsets.all(8.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return PatternCard(
            imageAssetPath: 'assets/patterns/$index.png',
          );
        },
      ),
    );
  }
}
