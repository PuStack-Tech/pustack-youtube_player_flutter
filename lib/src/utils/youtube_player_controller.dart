// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../enums/playback_rate.dart';
import '../enums/player_state.dart';
import '../utils/youtube_meta_data.dart';
import '../widgets/progress_bar.dart';
import 'youtube_player_flags.dart';

/// [ValueNotifier] for [YoutubePlayerController].
class YoutubePlayerValue {
  /// The duration, current position, buffering state, error state and settings
  /// of a [YoutubePlayerController].
  YoutubePlayerValue({
    this.seekDelta = 15,
    this.isReady = false,
    this.isControlsVisible = false,
    this.hasPlayed = false,
    this.position = const Duration(),
    this.buffered = 0.0,
    this.isPlaying = false,
    this.isFullScreen = false,
    this.volume = 100,
    this.playerState = PlayerState.unknown,
    this.playbackRate = PlaybackRate.normal,
    this.playbackQuality,
    this.errorCode = 0,
    this.webViewController,
    this.isDragging = false,
    this.metaData = const YoutubeMetaData(),
  });

  /// Returns true when the player is ready to play videos.
  final bool isReady;

  /// Defines whether or not the controls are visible.
  final bool isControlsVisible;

  /// Returns true once the video start playing for the first time.
  final bool hasPlayed;

  /// The current position of the video.
  final Duration position;

  /// The position up to which the video is buffered.i
  final double buffered;

  /// Reports true if video is playing.
  final bool isPlaying;

  /// Reports true if video is fullscreen.
  bool isFullScreen;

  /// The current volume assigned for the player.
  final int volume;

  /// The current state of the player defined as [PlayerState].
  final PlayerState playerState;

  /// The current video playback rate defined as [PlaybackRate].
  final double playbackRate;

  /// Reports the error code as described [here](https://developers.google.com/youtube/iframe_api_reference#Events).
  ///
  /// See the onError Section.
  final int errorCode;

  /// Reports the [WebViewController].
  final InAppWebViewController? webViewController;

  /// Returns true is player has errors.
  bool get hasError => errorCode != 0;

  /// Reports the current playback quality.
  final String? playbackQuality;

  /// Returns true if [ProgressBar] is being dragged.
  final bool isDragging;

  /// Returns meta data of the currently loaded/cued video.
  final YoutubeMetaData metaData;

  final int seekDelta;

  /// Creates new [YoutubePlayerValue] with assigned parameters and overrides
  /// the old one.
  YoutubePlayerValue copyWith({
    int seekDelta = 15,
    bool? isReady,
    bool? isControlsVisible,
    bool? isLoaded,
    bool? hasPlayed,
    Duration? position,
    double? buffered,
    bool? isPlaying,
    bool? isFullScreen,
    double? volume,
    PlayerState? playerState,
    double? playbackRate,
    String? playbackQuality,
    int? errorCode,
    InAppWebViewController? webViewController,
    bool? isDragging,
    YoutubeMetaData? metaData,
  }) {
    return YoutubePlayerValue(
      seekDelta: seekDelta,
      //  ?? this.seekDelta,
      isReady: isReady ?? this.isReady,
      isControlsVisible: isControlsVisible ?? this.isControlsVisible,
      hasPlayed: hasPlayed ?? this.hasPlayed,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      volume: volume as int? ?? this.volume,
      playerState: playerState ?? this.playerState,
      playbackRate: playbackRate ?? this.playbackRate,
      playbackQuality: playbackQuality ?? this.playbackQuality,
      errorCode: errorCode ?? this.errorCode,
      webViewController: webViewController ?? this.webViewController,
      isDragging: isDragging ?? this.isDragging,
      metaData: metaData ?? this.metaData,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'metaData: ${metaData.toString()}, '
        'isReady: $isReady, '
        'isControlsVisible: $isControlsVisible, '
        'position: ${position.inSeconds} sec. , '
        'buffered: $buffered, '
        'isPlaying: $isPlaying, '
        'volume: $volume, '
        'playerState: $playerState, '
        'playbackRate: $playbackRate, '
        'playbackQuality: $playbackQuality, '
        'errorCode: $errorCode)';
  }
}

/// Controls a youtube player, and provides updates when the state is
/// changing.
///
/// The video is displayed in a Flutter app by creating a [YoutubePlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class YoutubePlayerController extends ValueNotifier<YoutubePlayerValue> {
  /// The video id with which the player initializes.
  final String initialVideoId;

  /// Composes all the flags required to control the player.
  final YoutubePlayerFlags flags;

  /// Creates [YoutubePlayerController].
  YoutubePlayerController({
    required this.initialVideoId,
    this.flags = const YoutubePlayerFlags(),
  }) : super(YoutubePlayerValue());

  /// Finds [YoutubePlayerController] in the provided context.
  factory YoutubePlayerController.of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedYoutubePlayer>()!
      .controller;

  String? _callMethod(String methodString) {
    if (value.isReady) {
      value.webViewController?.evaluateJavascript(source: methodString);
    } else {
      print(
          'youtube player controller _callMethod error: The controller is not ready for $methodString calls.');
      return "not_ready_error";
    }
    return null;
  }

  // ignore: use_setters_to_change_properties
  /// Updates the old [YoutubePlayerValue] with new one provided.
  void updateValue(YoutubePlayerValue newValue) => value = newValue;

  /// Plays the video.
  void play() => _callMethod('play()');

  /// Pauses the video.
  void pause() => _callMethod('pause()');

  /// Loads the video as per the [videoId] provided.
  void load(String? videoId, {int startAt = 0, int? endAt}) {
    var loadParams = 'videoId:"$videoId",startSeconds:$startAt';
    if (endAt != null && endAt > startAt) {
      loadParams += ',endSeconds:$endAt';
    }
    _updateValues(videoId);
    if (value.errorCode == 1) {
      print('youtube load error, pausing the video');
      pause();
    } else {
      String? error = _callMethod('loadById({$loadParams})');
      if (error == "not_ready_error") {
        throw Exception('not_ready_error');
      }
    }
  }

  /// Cues the video as per the [videoId] provided.
  void cue(String videoId, {int startAt = 0, int? endAt}) {
    var cueParams = 'videoId:"$videoId",startSeconds:$startAt';
    if (endAt != null && endAt > startAt) {
      cueParams += ',endSeconds:$endAt';
    }
    _updateValues(videoId);
    if (value.errorCode == 1) {
      print('youtube load error, pausing the video');
      pause();
    } else {
      _callMethod('cueById({$cueParams})');
    }
  }

  void _updateValues(String? id) {
    if (id?.length != 11) {
      updateValue(
        value.copyWith(
          errorCode: 1,
        ),
      );
      return;
    }
    updateValue(
      value.copyWith(errorCode: 0, hasPlayed: false),
    );
  }

  /// Mutes the player.
  void mute() => _callMethod('mute()');

  /// Un mutes the player.
  void unMute() => _callMethod('unMute()');

  /// Sets the volume of player.
  /// Max = 100 , Min = 0
  void setVolume(int volume) => volume >= 0 && volume <= 100
      ? _callMethod('setVolume($volume)')
      : throw Exception("Volume should be between 0 and 100");

  /// Seek to any position. Video auto plays after seeking.
  /// The optional allowSeekAhead parameter determines whether the player will make a new request to the server
  /// if the seconds parameter specifies a time outside of the currently buffered video data.
  /// Default allowSeekAhead = true
  void seekTo(Duration position, {bool allowSeekAhead = true}) {
    _callMethod('seekTo(${position.inSeconds},$allowSeekAhead)');
    play();
    updateValue(value.copyWith(position: position));
  }

  void seekAhead() {
    int maxDuration = metadata.duration.inSeconds - 1;
    int goal = value.position.inSeconds + value.seekDelta;
    goal = goal > maxDuration ? maxDuration : goal;
    seekTo(Duration(seconds: goal));
  }

  void seekBefore() {
    int minDuration = 0;
    int goal = value.position.inSeconds - value.seekDelta;
    goal = goal < minDuration ? minDuration : goal;
    seekTo(Duration(seconds: goal));
  }

  /// Sets the size in pixels of the player.
  void setSize(Size size) =>
      _callMethod('setSize(${size.width}, ${size.height})');

  /// Fits the video to screen width.
  void fitWidth(Size screenSize) {
    var adjustedHeight = 9 / 16 * screenSize.width;
    setSize(Size(screenSize.width, adjustedHeight));
    _callMethod(
      'setTopMargin("-${((adjustedHeight - screenSize.height) / 2 * 100).abs()}px")',
    );
  }

  /// Fits the video to screen height.
  void fitHeight(Size screenSize) {
    setSize(screenSize);
    _callMethod('setTopMargin("0px")');
  }

  /// Sets the playback speed for the video.
  void setPlaybackRate(double rate) => _callMethod('setPlaybackRate($rate)');

  /// Toggles the player's full screen mode.
  void toggleFullScreenMode() {
    updateValue(value.copyWith(isFullScreen: !value.isFullScreen));

    if (value.isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: flags.systemOverlaysAfterFullScreen);
      SystemChrome.setPreferredOrientations(
          flags.deviceOrientationsAfterFullScreen);
    }
  }

  /// MetaData for the currently loaded or cued video.
  YoutubeMetaData get metadata => value.metaData;

  /// Reloads the player.
  ///
  /// The video id will reset to [initialVideoId] after reload.
  void reload() => value.webViewController?.reload();

  /// Resets the value of [YoutubePlayerController].
  void reset() => updateValue(
        value.copyWith(
          isReady: false,
          isFullScreen: false,
          isControlsVisible: false,
          playerState: PlayerState.unknown,
          hasPlayed: false,
          position: Duration.zero,
          buffered: 0.0,
          errorCode: 0,
          isLoaded: false,
          isPlaying: false,
          isDragging: false,
          metaData: const YoutubeMetaData(),
        ),
      );
}

/// An inherited widget to provide [YoutubePlayerController] to it's descendants.
class InheritedYoutubePlayer extends InheritedWidget {
  /// Creates [InheritedYoutubePlayer]
  const InheritedYoutubePlayer({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// A [YoutubePlayerController] which controls the player.
  final YoutubePlayerController controller;

  @override
  bool updateShouldNotify(InheritedYoutubePlayer oldPlayer) =>
      oldPlayer.controller.hashCode != controller.hashCode;
}
