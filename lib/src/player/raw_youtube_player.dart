// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../enums/player_state.dart';
import '../utils/youtube_meta_data.dart';
import '../utils/youtube_player_controller.dart';

/// A raw youtube player widget which interacts with the underlying webview inorder to play YouTube videos.
///
/// Use [YoutubePlayer] instead.
class RawYoutubePlayer extends StatefulWidget {
  /// Sets [Key] as an identification to underlying web view associated to the player.
  final Key? key;

  /// {@macro youtube_player_flutter.onEnded}
  final void Function(YoutubeMetaData metaData)? onEnded;

  /// Creates a [RawYoutubePlayer] widget.
  RawYoutubePlayer({
    this.key,
    this.onEnded,
  });

  @override
  _RawYoutubePlayerState createState() => _RawYoutubePlayerState();
}

class _RawYoutubePlayerState extends State<RawYoutubePlayer>
    with WidgetsBindingObserver {
  YoutubePlayerController? controller;
  PlayerState? _cachedPlayerState;
  bool _isPlayerReady = false;
  bool _onLoadStopCalled = false;

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_cachedPlayerState != null &&
            _cachedPlayerState == PlayerState.playing) {
          controller?.play();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _cachedPlayerState = controller!.value.playerState;
        controller?.pause();
        break;
      default:
    }
  }

  Map<int, String> stateMap = {
    -1: 'unStarted',
    0: 'ended',
    1: 'playing',
    2: 'paused',
    3: 'buffering',
    5: 'cued',
    6: 'preloading',
  };

  @override
  Widget build(BuildContext context) {
    controller = YoutubePlayerController.of(context);
    return IgnorePointer(
      ignoring: true,
      child: InAppWebView(
        key: widget.key,
        initialData: InAppWebViewInitialData(
          data: player,
          baseUrl: Uri.parse('https://www.youtube.com'),
          encoding: 'utf-8',
          mimeType: 'text/html',
        ),
        initialOptions: InAppWebViewGroupOptions(
          ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true, ),
          crossPlatform: InAppWebViewOptions(
            userAgent: userAgent ?? "",
            mediaPlaybackRequiresUserGesture: false,
            transparentBackground: true,
            clearCache: true,
            cacheEnabled: false,
            incognito: true,
          ),
        ),
        onWebViewCreated: (webController) {
          controller!.updateValue(
              controller!.value.copyWith(webViewController: webController));
          webController
            ..addJavaScriptHandler(
              handlerName: 'Ready',
              callback: (_) {
                _isPlayerReady = true;
                if (_onLoadStopCalled) {
                  controller!.updateValue(
                    controller!.value.copyWith(isReady: true),
                  );
                }
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'StateChange',
              callback: (args) {
                if (controller!.value.playerState != PlayerState.preLoading) {
                  switch (args.first as int?) {
                    case -1:
                      controller!.updateValue(
                        controller!.value.copyWith(
                          playerState: PlayerState.unStarted,
                          isLoaded: true,
                        ),
                      );
                      break;
                    case 0:
                      if (widget.onEnded != null) {
                        widget.onEnded!(controller!.metadata);
                      }

                      controller!.updateValue(
                        controller!.value.copyWith(
                          playerState: PlayerState.ended,
                        ),
                      );
                      break;
                    case 1:
                      controller!.updateValue(
                        controller!.value.copyWith(
                          playerState: PlayerState.playing,
                          isPlaying: true,
                          hasPlayed: true,
                          errorCode: 0,
                        ),
                      );
                      break;
                    case 2:
                      controller!.updateValue(
                        controller!.value.copyWith(
                          playerState: PlayerState.paused,
                          isPlaying: false,
                        ),
                      );

                      break;
                    case 3:
                      controller!.updateValue(
                        controller!.value.copyWith(
                          playerState: PlayerState.buffering,
                        ),
                      );
                      break;
                    case 5:
                      controller!.updateValue(
                        controller!.value.copyWith(
                          playerState: PlayerState.cued,
                        ),
                      );
                      break;
                    case 6:
                      controller!.updateValue(
                        controller!.value.copyWith(
                          playerState: PlayerState.preLoading,
                        ),
                      );
                      break;
                    default:
                      print('Invalid player state obtained.');
                      throw Exception("Invalid player state obtained.");
                  }
                } else if (controller!.value.playerState ==
                        PlayerState.preLoading &&
                    (args.first as int?) == 7) {
                  controller!.updateValue(
                    controller!.value.copyWith(
                      playerState: PlayerState.playing,
                      isPlaying: true,
                      isLoaded: true,
                    ),
                  );
                }
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'PlaybackQualityChange',
              callback: (args) {
                print('play back quality change: ${args.first}');
                controller!.updateValue(
                  controller!.value
                      .copyWith(playbackQuality: args.first as String?),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'PlaybackRateChange',
              callback: (args) {
                final num? rate = args.first;
                controller!.updateValue(
                  controller!.value.copyWith(
                      playbackRate: rate == null ? 1.0 : rate.toDouble()),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'Errors',
              callback: (args) {
                controller!.updateValue(
                  controller!.value.copyWith(errorCode: args.first as int?),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'VideoData',
              callback: (args) {
                controller!.updateValue(
                  controller!.value.copyWith(
                      metaData: YoutubeMetaData.fromRawData(args.first)),
                );
              },
            )
            ..addJavaScriptHandler(
              handlerName: 'VideoTime',
              callback: (args) {
                final position = args.first * 1000;
                final num? buffered = args.last;
                controller!.updateValue(
                  controller!.value.copyWith(
                    position: Duration(milliseconds: position.floor()),
                    buffered: buffered == null ? 0.0 : buffered.toDouble(),
                  ),
                );
              },
            );
        },
        onLoadStop: (_, __) {
          _onLoadStopCalled = true;
          if (_isPlayerReady) {
            controller!.updateValue(
              controller!.value.copyWith(isReady: true),
            );
          }
        },
      ),
    );
  }

  String get player => '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            html,
            body {
                margin: 0;
                padding: 0;
                background-color: #000000;
                overflow: hidden;
                position: fixed;
                height: 100%;
                width: 100%; 
                pointer-events: none; 
            }
            
        </style>
        <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
    </head>
    <body>
        <div id="player"></div>
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
            var player;
            var timerId;
            var checkHasPlayedTimer;
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    height: '100%',
                    width: '100%',
                    videoId: '${controller!.initialVideoId}',
                    playerVars: {
                        'controls': 0,
                        'playsinline': 1,
                        'enablejsapi': 1,
                        'fs': 0,
                        'rel': 0,
                        'showinfo': 0,
                        'iv_load_policy': 3,
                        'modestbranding': 1,
                        'cc_load_policy': ${boolean(value: controller!.flags.enableCaption)},
                        'cc_lang_pref': '${controller!.flags.captionLanguage}',
                        'autoplay': 0,
                        'start': ${controller!.flags.startAt},
                        'end': ${controller!.flags.endAt}
                    },
                    events: {
                        onReady: function(event) { sendVideoData(player, true); 
                        ${controller!.flags.autoPlay ? 'preLoad(true);' : 'preLoad(false)'}
                        window.flutter_inappwebview.callHandler('Ready'); },
                        onStateChange: function(event) { sendPlayerStateChange(event.data); },
                        onPlaybackQualityChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackQualityChange', event.data); },
                        onPlaybackRateChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackRateChange', event.data); },
                        onError: function(error) { window.flutter_inappwebview.callHandler('Errors', error.data); }
                    },
                });
            }
 
        
            var shouldRestart = true;
            
            function preLoad(autoPlay) {
                window.flutter_inappwebview.callHandler('StateChange', 6);
                mute(); 
                player.playVideo();
                startCheckHasPlayedTimer(autoPlay)
            }
            
            function clear(autoPlay) {
               clearTimeout(checkHasPlayedTimer);
               pause();
               window.flutter_inappwebview.callHandler('VideoTime', 0, player.getVideoLoadedFraction());
               window.flutter_inappwebview.callHandler('StateChange', 7);
               if (autoPlay) {
                 play(); 
               }
            }

            function sendPlayerStateChange(playerState) {
                clearTimeout(timerId);
                window.flutter_inappwebview.callHandler('StateChange', playerState);
                if (playerState == 1 || playerState == 6) {
                  sendVideoData(player); 
                  startSendCurrentTimeInterval(); 
                }
            }

            function sendVideoData(player, isFirstVideo=false) {
                var videoData = {
                    'duration': player.getDuration(),
                    'title': player.getVideoData().title,
                    'author': player.getVideoData().author,
                    'videoId': player.getVideoData().video_id,
                    'isFirstVideo': isFirstVideo,
                };
                window.flutter_inappwebview.callHandler('VideoData', videoData);
            }

            function startCheckHasPlayedTimer(autoPlay) {
              checkHasPlayedTimer = setInterval(function () {
                    if (player.getCurrentTime() >= 1) {
                      clear(autoPlay);
                    }
                }, 100);
            }
            function startSendCurrentTimeInterval() {
                timerId = setInterval(function () {
                    window.flutter_inappwebview.callHandler('VideoTime', player.getCurrentTime(), player.getVideoLoadedFraction());
                }, 100);
            }

            function play() {
              clearTimeout(checkHasPlayedTimer);
              if (shouldRestart) {
                if (${!controller!.flags.mute}) {
                 unMute();
                }
              
                seekTo(0, true);
                shouldRestart = false;
                }
               
                player.playVideo();
              
                return '';
            }

            function pause() {
                player.pauseVideo();
                return '';
            }

            function loadById(loadSettings) {
              clearTimeout(checkHasPlayedTimer);
              window.flutter_inappwebview.callHandler('StateChange', 6);
              var videoData = {
                  'videoId': loadSettings['videoId'],
              };
              window.flutter_inappwebview.callHandler('VideoData', videoData);
              shouldRestart = true;
              mute(); 
              player.loadVideoById(loadSettings);   
                  startCheckHasPlayedTimer(true); 
              return ''; 
                 
            }

            function cueById(cueSettings) {
                player.cueVideoById(cueSettings);
                return '';
            }

            function loadPlaylist(playlist, index, startAt) {
                player.loadPlaylist(playlist, 'playlist', index, startAt);
                return '';
            }

            function cuePlaylist(playlist, index, startAt) {
                player.cuePlaylist(playlist, 'playlist', index, startAt);
                return '';
            }

            function mute() {
                player.mute();
                return '';
            }

            function unMute() {
                player.unMute();
                return '';
            }

            function setVolume(volume) {
                player.setVolume(volume);
                return '';
            }

            function seekTo(position, seekAhead) {
                if (shouldRestart) {
                    shouldRestart = false;
                }
                player.seekTo(position, seekAhead);
                return '';
            }

            function setSize(width, height) {
                player.setSize(width, height);
                return '';
            }

            function setPlaybackRate(rate) {
                player.setPlaybackRate(rate);
                return '';
            }

            function setTopMargin(margin) {
                document.getElementById("player").style.marginTop = margin;
                return '';
            }
        </script>
    </body>
    </html>
  ''';

  String boolean({required bool value}) => value ? "'1'" : "'0'";

  String? get userAgent => controller!.flags.forceHD
      ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36'
      : null;
}
