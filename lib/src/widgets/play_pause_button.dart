// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../enums/player_state.dart';
import '../utils/youtube_player_controller.dart';

/// A widget to display play/pause button.
class PlayPauseButton extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines placeholder widget to show when player is in buffering state.
  final Widget? bufferIndicator;

  /// Creates [PlayPauseButton] widget.
  PlayPauseButton({
    this.controller,
    this.bufferIndicator,
  });

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with TickerProviderStateMixin {
  YoutubePlayerController? _controller;
  late AnimationController _animController;

  late Animation _forwardAnimation;
  late AnimationController _forwardAnimationController;
  late Animation _backwardAnimation;
  late AnimationController _backwardAnimationController;

  @override
  void initState() {
    super.initState();
    _forwardAnimationController = AnimationController(
        duration: Duration(milliseconds: 100),
        reverseDuration: Duration(milliseconds: 50),
        vsync: this);
    _forwardAnimation = _forwardAnimationController.drive(Tween<double>(
      begin: 1,
      end: 0.75,
    ));
    _forwardAnimation.addListener(() {
      setState(() {});
    });

    _backwardAnimationController = AnimationController(
        duration: Duration(milliseconds: 100),
        reverseDuration: Duration(milliseconds: 50),
        vsync: this);
    _backwardAnimation = _backwardAnimationController.drive(Tween<double>(
      begin: 1,
      end: 0.75,
    ));
    _backwardAnimation.addListener(() {
      setState(() {});
    });

    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 300),
    );
  }

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
    _controller!.removeListener(_playPauseListener);
    _controller!.addListener(_playPauseListener);
  }

  @override
  void dispose() {
    _controller?.removeListener(_playPauseListener);
    _animController.dispose();
    super.dispose();
  }

  void _playPauseListener() => _controller!.value.isPlaying
      ? _animController.forward()
      : _animController.reverse();

  @override
  Widget build(BuildContext context) {
    final _playerState = _controller!.value.playerState;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double iconSize = 36;

    return Stack(
      children: [
        Visibility(
          visible: _controller!.value.isReady &&
              !_controller!.flags.isLive &&
              !_controller!.flags.isRecorded &&
              _playerState != PlayerState.preLoading &&
              (((_playerState != PlayerState.playing &&
                          _playerState != PlayerState.paused &&
                          _playerState != PlayerState.buffering) ||
                      _controller!.value.isControlsVisible) &&
                  _controller!.value.position.inSeconds > 0),
          child: Container(
            width: width,
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _controller!.seekBefore();
                      _backwardAnimationController.reset();
                      _backwardAnimationController.forward().then((value) {
                        _backwardAnimationController.reverse();
                      });
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Transform.scale(
                      scale: _backwardAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.all(
                            _controller!.value.isFullScreen ? 60 : 24.0),
                        child: Stack(
                          children: [
                            Container(
                              child: SvgPicture.asset(
                                'assets/backward_double.svg',
                                package: 'youtube_player_flutter',
                                color: Colors.white,
                                width: iconSize,
                                height: iconSize,
                              ),
                            ),
                            Container(
                              width: iconSize,
                              height: iconSize,
                              child: Center(
                                child: Text(
                                  '${_controller!.value.seekDelta}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controller!.seekAhead();
                      _forwardAnimationController.reset();
                      _forwardAnimationController.forward().then((value) {
                        _forwardAnimationController.reverse();
                      });
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Transform.scale(
                      scale: _forwardAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.all(
                            _controller!.value.isFullScreen ? 60 : 24.0),
                        child: Stack(
                          children: [
                            Container(
                              child: SvgPicture.asset(
                                'assets/forward_double.svg',
                                package: 'youtube_player_flutter',
                                color: Colors.white,
                                width: iconSize,
                                height: iconSize,
                              ),
                            ),
                            Container(
                              width: iconSize,
                              height: iconSize,
                              child: Center(
                                child: Text(
                                  '${_controller!.value.seekDelta}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Lato',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Builder(builder: (builderContext) {
            if ((_controller!.value.isReady &&
                    _playerState != PlayerState.preLoading &&
                    _playerState != PlayerState.buffering) ||
                _playerState == PlayerState.playing ||
                _playerState == PlayerState.paused) {
              return Visibility(
                visible: _playerState == PlayerState.cued ||
                    (!_controller!.value.isPlaying &&
                        _controller!.value.playerState != PlayerState.paused) ||
                    _controller!.value.isControlsVisible,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50.0),
                    onTap: () => _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.flags.isLive
                            ? _controller!
                                .seekTo(_controller!.metadata.duration)
                            : _controller!.flags.isRecorded
                                ? _controller!.seekTo(Duration(
                                    milliseconds: DateTime.now()
                                            .millisecondsSinceEpoch -
                                        (_controller!.flags.startTs as int)))
                                : _controller!.play(),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _animController.view,
                      color: Colors.white,
                      size: _controller!.flags.iconSize,
                    ),
                  ),
                ),
              );
            }
            if (_controller!.value.hasError)
              return const SizedBox();
            else if ((!_controller!.value.isReady ||
                    _playerState == PlayerState.preLoading) ||
                _playerState == PlayerState.buffering) {
              return widget.bufferIndicator ??
                  Container(
                    width: _controller!.flags.iconSize,
                    height: _controller!.flags.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: _controller!.flags.iconSize > 40 ? 6 : 4,
                      valueColor: AlwaysStoppedAnimation(Colors.grey[200]),
                    ),
                  );
            } else {
              return Container();
            }
          }),
        ),
      ],
    );
  }
}
