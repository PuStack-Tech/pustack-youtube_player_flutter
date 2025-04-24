import 'package:flutter/services.dart';

// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines player flags for [YoutubePlayer].
class YoutubePlayerFlags {
  /// If set to true, hides the controls.
  ///
  /// Default is false.
  final bool hideControls;

  /// Is set to true, controls will be visible at start.
  ///
  /// Default is false.
  final bool controlsVisibleAtStart;

  /// Define whether to auto play the video after initialization or not.
  ///
  /// Default is true.
  final bool autoPlay;

  /// Mutes the player initially
  ///
  /// Default is false.
  final bool mute;

  /// if true, Live Playback controls will be shown instead of default one.
  ///
  /// Default is false.
  final bool isLive;

  /// Hides thumbnail if true.
  ///
  /// Default is false.
  final bool hideThumbnail;

  /// Disables seeking video position when dragging horizontally.
  ///
  /// Default is false.
  final bool disableDragSeek;

  /// Enabling this causes the player to play the video again and again.
  ///
  /// Default is false.
  final bool loop;

  /// Enabling causes closed captions to be shown by default.
  ///
  /// Default is true.
  final bool enableCaption;

  /// Specifies the default language that the player will use to display captions. Set the parameter's value to an [ISO 639-1 two-letter language code](http://www.loc.gov/standards/iso639-2/php/code_list.php).
  ///
  /// Default is `en`.
  final String captionLanguage;

  /// Forces High Definition video quality when possible
  ///
  /// Default is false.
  final bool forceHD;

  /// Specifies the default starting point of the video in seconds
  ///
  /// Default is 0.
  final int startAt;

  /// Specifies the default end point of the video in seconds
  final int? endAt;

  final bool showMask;

  final double iconSize;
  final bool enableFullScreen;
  final bool constantScale;
  final bool isRecorded;
  final bool isReplay;
  final int? startTs;

  /// Defines the system overlays visible after exiting fullscreen
  final List<SystemUiOverlay> systemOverlaysAfterFullScreen;

  /// Defines the set of allowed device orientations after exiting fullscreen
  final List<DeviceOrientation> deviceOrientationsAfterFullScreen;

  /// Creates [YoutubePlayerFlags].
  const YoutubePlayerFlags({
    this.constantScale = true,
    this.showMask = true,
    this.hideControls = false,
    this.controlsVisibleAtStart = false,
    this.autoPlay = true,
    this.mute = false,
    this.isLive = false,
    this.hideThumbnail = false,
    this.disableDragSeek = true,
    this.enableCaption = true,
    this.captionLanguage = 'en',
    this.loop = false,
    this.forceHD = false,
    this.startAt = 0,
    this.endAt,
    this.iconSize = 60,
    this.enableFullScreen = true,
    this.isRecorded = false,
    this.startTs,
    this.isReplay = false,
    this.systemOverlaysAfterFullScreen = const [
      SystemUiOverlay.bottom,
      SystemUiOverlay.top
    ],
    this.deviceOrientationsAfterFullScreen = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  });

  /// Copies new values assigned to the [YoutubePlayerFlags].
  YoutubePlayerFlags copyWith({
    bool? constantScale,
    bool? showLiveBottomBar,
    bool? showPlayPause,
    bool? hideControls,
    bool? autoPlay,
    bool? mute,
    bool? showVideoProgressIndicator,
    bool? isLive,
    bool? hideThumbnail,
    bool? disableDragSeek,
    bool? loop,
    bool? enableCaption,
    bool? forceHD,
    String? captionLanguage,
    int? startAt,
    int? endAt,
    double? iconSize,
    bool? enableFullScreen,
  }) {
    return YoutubePlayerFlags(
      constantScale: constantScale ?? this.constantScale,
      autoPlay: autoPlay ?? this.autoPlay,
      captionLanguage: captionLanguage ?? this.captionLanguage,
      disableDragSeek: disableDragSeek ?? this.disableDragSeek,
      enableCaption: enableCaption ?? this.enableCaption,
      hideControls: hideControls ?? this.hideControls,
      hideThumbnail: hideThumbnail ?? this.hideThumbnail,
      isLive: isLive ?? this.isLive,
      loop: loop ?? this.loop,
      mute: mute ?? this.mute,
      forceHD: forceHD ?? this.forceHD,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      iconSize: iconSize ?? this.iconSize,
      enableFullScreen: enableFullScreen ?? this.enableFullScreen,
      systemOverlaysAfterFullScreen: systemOverlaysAfterFullScreen,
      deviceOrientationsAfterFullScreen: deviceOrientationsAfterFullScreen,
    );
  }
}
