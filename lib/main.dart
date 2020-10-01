import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gone fishing.',
      home: Scaffold(
        body: MyRiveAnimation(),
      ),
    );
  }
}

class MyRiveAnimation extends StatefulWidget {
  @override
  _MyRiveAnimationState createState() => _MyRiveAnimationState();
}

class _MyRiveAnimationState extends State<MyRiveAnimation> {
  final riveFileName = 'assets/truck.riv';
  Artboard _artboard;
  WiperAnimation _wipersController;
  // Flag to turn wipers on and off
  bool _wipers = false;

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  // Load the rive file from flutters assets
  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile();

    if (file.import(bytes)) {
      // Select animations by name
      // And wrap them with a SimpleAnimation that autoplays
      setState(() => _artboard = file.mainArtboard
        ..addController(
          SimpleAnimation('idle'),
        ));
    }
  }

  void _wipersChange(bool wipersOn) {
    if (_wipersController == null) {
      // Add an additional controller onto the artboard, the controller
      // auto plays once added
      _artboard.addController(
        _wipersController = WiperAnimation('windshield_wipers'),
      );
    }
    if (wipersOn) {
      _wipersController.start();
    } else {
      _wipersController.stop();
    }
    setState(() => _wipers = wipersOn);
  }

  /// Show the rive file, when loaded
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _artboard != null
              ? Rive(
                  artboard: _artboard,
                  fit: BoxFit.cover,
                )
              : Container(),
        ),
        SizedBox(
          height: 50,
          width: 200,
          child: SwitchListTile(
            title: const Text('Wipers'),
            value: _wipers,
            onChanged: _wipersChange,
          ),
        ),
      ],
    );
  }
}

class WiperAnimation extends SimpleAnimation {
  WiperAnimation(String animationName) : super(animationName);

  start() {
    // When starting the wiper animation we want the loop mode to be 'loop'
    // and set the animation to be active.
    instance.animation.loop = Loop.loop;
    isActive = true;
  }

  stop() {
    // We want the animation to play to the end of its loop
    // so we set the loop mode to oneShot.
    instance.animation.loop = Loop.oneShot;
  }
}
