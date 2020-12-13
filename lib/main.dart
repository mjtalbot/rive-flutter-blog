import 'dart:math';

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
  TruckController _truckController;
  // Flag to turn wipers on and off
  bool _wipers = false;

  // Flag to turn suspension on and off
  bool _suspension = false;

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

  void _suspensionChange(bool suspensionOn) {
    if (_truckController == null) {
      // Add an additional controller onto the artboard, the controller
      // auto plays once added
      _artboard.addController(
        _truckController = TruckController(),
      );
    }
    if (suspensionOn) {
      _truckController.suspensionOn = suspensionOn;
    } else {
      _truckController.suspensionOn = suspensionOn;
    }
    setState(() => _suspension = suspensionOn);
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
        Row(
          children: [
            SizedBox(
              height: 50,
              width: 200,
              child: SwitchListTile(
                title: const Text('Wipers'),
                value: _wipers,
                onChanged: _wipersChange,
              ),
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: SwitchListTile(
                title: const Text('Suspension'),
                value: _suspension,
                onChanged: _suspensionChange,
              ),
            ),
          ],
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

class TruckController extends RiveAnimationController<RuntimeArtboard> {
  LinearAnimationInstance _suspensionAnimation;
  TruckController();

  var _suspensionOn = false;
  bool get suspensionOn => _suspensionOn;
  set suspensionOn(bool suspensionOn) {
    _suspensionOn = suspensionOn;
  }

  LinearAnimationInstance _getAnimationInstance(
      RuntimeArtboard artboard, String animationName) {
    var animation = artboard.animations.firstWhere(
      (animation) =>
          animation is LinearAnimation && animation.name == animationName,
      orElse: () => null,
    );
    if (animation != null) {
      return LinearAnimationInstance(animation as LinearAnimation);
    }
    return null;
  }

  @override
  bool init(RuntimeArtboard artboard) {
    _suspensionAnimation = _getAnimationInstance(artboard, 'bouncing');
    isActive = true;
    return _suspensionAnimation != null;
  }

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    if (suspensionOn) {
      _suspensionAnimation.animation.apply(
        _suspensionAnimation.time,
        coreContext: artboard,
        mix: 1.0,
      );
      _suspensionAnimation.advance(elapsedSeconds);
    }
  }

  @override
  void dispose() {}

  @override
  void onActivate() {}

  @override
  void onDeactivate() {}
}

class LinearMixer {
  final double start;
  final double finish;
  final double duration;
  double time;
  double mixValue;

  LinearMixer(this.start, this.finish, this.duration)
      : time = 0,
        mixValue = start;

  void apply(double elapsedTime) {
    if (time > duration) {
      return;
    }
    time += elapsedTime;
    var completion = (min(time, duration)) / (duration);
    mixValue = (finish - start) * completion + start;
  }
}
