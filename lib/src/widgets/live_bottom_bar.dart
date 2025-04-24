// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../youtube_player_flutter.dart';
import '../utils/youtube_player_controller.dart';
import 'full_screen_button.dart';

/// A widget to display bottom controls bar on Live Video Mode.
class LiveBottomBar extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines color for UI.
  final Color liveUIColor;

  final bool isReplay;

  final ProgressBarColors progressBarColors;

  /// Creates [LiveBottomBar] widget.
  LiveBottomBar({
    this.controller,
    required this.liveUIColor,
    required this.isReplay,
    required this.progressBarColors,
  });

  @override
  _LiveBottomBarState createState() => _LiveBottomBarState();
}

class _LiveBottomBarState extends State<LiveBottomBar> {
  double _currentSliderPosition = 0.0;

  YoutubePlayerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = YoutubePlayerController.of(context);
    if (_controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller;
    }
    _controller!.addListener(listener);
  }

  @override
  void dispose() {
    _controller?.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (mounted) {
      setState(() {
        _currentSliderPosition =
            _controller!.metadata.duration.inMilliseconds == 0
                ? 0
                : _controller!.value.position.inMilliseconds /
                    _controller!.metadata.duration.inMilliseconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _controller!.value.isControlsVisible,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 14.0,
          ),
          widget.isReplay
              ? ProgressBar(
                  isExpanded: true,
                  colors: widget.progressBarColors,
                )
              : Expanded(child: Container()),
          InkWell(
            onTap: () => _controller!.seekTo(_controller!.metadata.duration),
            child: Material(
              color: widget.liveUIColor,
              child: Padding(
                padding: EdgeInsets.all(widget.isReplay ? 2.0 : 0),
                child: Text(
                  widget.isReplay ? ' REPLAY' : ' LIVE ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
          // if (widget.isReplay)
          //   PlaybackSpeedButton(
          //     controller: _controller,
          //   ),
          if (_controller!.flags.enableFullScreen)
            FullScreenButton(
              controller: _controller,
              onToggleButtonTap: (){},
            )
          else
            SizedBox(
              width: 14,
              height: 28,
            )
        ],
      ),
    );
  }
}
