import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import 'AudioSeekBar.dart';

const double _playButtonSize = 32.0;

class AudioPlayerInline extends StatefulWidget {
  final String url;
  final VoidCallback? onPlay;
  const AudioPlayerInline({Key? key, required this.url, this.onPlay})
      : super(key: key);

  @override
  _AudioPlayerInlineState createState() => _AudioPlayerInlineState(url, onPlay);
}

class _AudioPlayerInlineState extends State<AudioPlayerInline> {
  final AudioPlayer _player = AudioPlayer();
  final String url;
  final VoidCallback? onPlay;

  bool _isActive = false;
  _AudioPlayerInlineState(this.url, [this.onPlay]);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    try {
      _player.dispose();
    } catch (_) {}
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display play/pause button and volume/speed sliders.

          // Display seek bar. Using StreamBuilder, this widget rebuilds
          // each time the position, buffered position or duration changes.
          Expanded(
            child: StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition:
                        positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: _player.seek,
                  ),
                );
              },
            ),
          ),
          _isActive
              ? ControlButtons(_player, onPlay)
              : IconButton(
                  icon: const FaIcon(FontAwesomeIcons.play),
                  iconSize: _playButtonSize,
                  onPressed: () async {
                    setState(() {
                      _isActive = true;
                    });
                    await _player.setUrl(url);
                    _player.play();
                  },
                ),
          // StreamBuilder<double>(
          //   stream: _player.speedStream,
          //   builder: (context, snapshot) => SizedBox(
          //     width: 50,
          //     child: IconButton(
          //       icon: Text(
          //         "${snapshot.data?.toStringAsFixed(1)}x",
          //         style: Theme.of(context).textTheme.headline3,
          //       ),
          //       onPressed: () {
          //         showSliderDialog(
          //           context: context,
          //           title: "تنظیم سرعت پخش",
          //           divisions: 5,
          //           min: 0.5,
          //           max: 3.0,
          //           value: _player.speed,
          //           stream: _player.speedStream,
          //           onChanged: _player.setSpeed,
          //         );
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;
  final VoidCallback? onPlay;

  ControlButtons(this.player, [this.onPlay]);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Opens volume slider dialog

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(12),
                width: _playButtonSize - 8,
                height: _playButtonSize - 8,
                child: CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const FaIcon(FontAwesomeIcons.play),
                iconSize: _playButtonSize,
                onPressed: () {
                  player.play();
                  if (onPlay != null) onPlay!();
                },
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const FaIcon(FontAwesomeIcons.pause),
                iconSize: _playButtonSize,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: _playButtonSize,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
      ],
    );
  }
}
