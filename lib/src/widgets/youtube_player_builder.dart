import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// A wrapper for [YoutubePlayer].
class YoutubePlayerBuilder extends StatefulWidget {
  /// The actual [YoutubePlayer].
  final YoutubePlayer player;

  /// Builds the widget below this [builder].
  final Widget Function(BuildContext, Widget) builder;

  /// Callback to notify that the player has entered fullscreen.
  final VoidCallback? onEnterFullScreen;

  /// Callback to notify that the player has exited fullscreen.
  final VoidCallback? onExitFullScreen;

  /// Builder for [YoutubePlayer] that supports switching between fullscreen and normal mode.
  const YoutubePlayerBuilder({
    Key? key,
    required this.player,
    required this.builder,
    this.onEnterFullScreen,
    this.onExitFullScreen,
  }) : super(key: key);

  @override
  _YoutubePlayerBuilderState createState() => _YoutubePlayerBuilderState();
}

class _YoutubePlayerBuilderState extends State<YoutubePlayerBuilder>
    with WidgetsBindingObserver {
  final GlobalKey playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // final physicalSize = SchedulerBinding.instance.window.physicalSize;
    // final controller = widget.player.controller;
    // if (physicalSize.width > physicalSize.height) {
    //   controller!.updateValue(controller.value.copyWith(isFullScreen: true));
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    //   if (widget.onEnterFullScreen != null) widget.onEnterFullScreen!();
    // } else {
    //   controller!.updateValue(controller.value.copyWith(isFullScreen: false));
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //       overlays: SystemUiOverlay.values);
    //   if (widget.onExitFullScreen != null) widget.onExitFullScreen!();
    // }
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final _player = Container(
      key: playerKey,
      child: Platform.isIOS
          ? widget.player
          : WillPopScope(
              onWillPop: () async {
                final controller = widget.player.controller!;
                if (controller.value.isFullScreen) {
                  widget.player.controller!.toggleFullScreenMode();
                  return false;
                }
                return true;
              },
              child: widget.player,
            ),
    );
    final child = widget.builder(context, _player);

    log("Is video full screen: ${widget.player.controller!.value.isFullScreen}",
        name: "YoutubePlayerBuilder");

    return OrientationBuilder(
      builder: (context, orientation) => orientation == Orientation.portrait
          ? child
          : widget.player.controller!.value.isFullScreen
              ? _player
              : child,
    );
  }
}
