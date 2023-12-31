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
  VoiceMessage({
    super.key,
    required this.voiceUrl,
    required this.chatBubbleColor,
  });

  final String voiceUrl;
  Color chatBubbleColor;
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
    player = AudioPlayer()..setUrl("${widget.voiceUrl}.mp3");
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.chatBubbleColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Controls(
            audioPlayer: player,
            voiceUrl: "${widget.voiceUrl}.mp3",
          ),
          Expanded(
            child: StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.only(top: 15.0, right: 15.0),
                  child: ProgressBar(
                    progress: positionData?.position ?? Duration.zero,
                    buffered: positionData?.bufferedPosition ?? Duration.zero,
                    total: positionData?.duration ?? Duration.zero,
                    onSeek: player.seek,
                    baseBarColor: Colors.white,
                    progressBarColor: Colors.white,
                    thumbColor: Colors.white,
                  ),
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
            color: Colors.white,
          );
        } else if (playing == true) {
          return IconButton(
            onPressed: audioPlayer.pause,
            icon: const Icon(Icons.pause_circle_rounded),
            iconSize: 45,
            color: Colors.white,
          );
        }

        return const Icon(
          Icons.play_arrow_rounded,
          size: 45,
          color: Colors.white,
        );
      },
    );
  }
}
