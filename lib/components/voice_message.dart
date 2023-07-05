import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );

  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({super.key, required this.voiceUrl});

  final String voiceUrl;

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  late AudioPlayer player; // Create a player

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();
    player = AudioPlayer()..setUrl(widget.voiceUrl);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 400,
      color: Colors.black,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Controls(
              audioPlayer: player,
              voiceUrl: widget.voiceUrl,
            ),
          ),
          Expanded(
            child: StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: player.seek,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({Key? key, required this.audioPlayer, required this.voiceUrl})
      : super(key: key);

  final AudioPlayer audioPlayer;
  final String voiceUrl;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (playing == false || processingState == ProcessingState.completed) {
          return IconButton(
            onPressed: () {
              audioPlayer.seek(Duration.zero);
              audioPlayer.setUrl(voiceUrl);
              audioPlayer.play();
            },
            icon: const Icon(Icons.play_arrow_rounded),
            iconSize: 45,
            color: Colors.red,
          );
        } else if (playing == true) {
          return IconButton(
            onPressed: audioPlayer.pause,
            icon: const Icon(Icons.pause_circle_rounded),
            iconSize: 45,
            color: Colors.red,
          );
        }

        return const Icon(
          Icons.play_arrow_rounded,
          size: 45,
          color: Colors.red,
        );
      },
    );
  }
}
