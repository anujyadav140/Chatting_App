import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_sound/flutter_sound.dart';

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({super.key});

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  late FlutterSoundRecorder myRecorder;
  late audio.AudioPlayer audioPlayer;
  bool isRecording = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String audioPath = '';
  late audio.Source urlSource;
  late String recordingUrl;
  @override
  void initState() {
    audioPlayer = audio.AudioPlayer();
    myRecorder = FlutterSoundRecorder();

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == audio.PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    myRecorder.dispositionStream();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      await myRecorder.openRecorder().then((e) async {
        var path = await myRecorder.startRecorder(
          codec: Codec.defaultCodec,
          toFile: 'foo',
        );
        return 'ok';
      });
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print("error recording stuff: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await myRecorder.stopRecorder();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
    } catch (e) {
      print("error stopping recording: $e");
    }
  }

  Future<void> playRecording() async {
    try {
      audio.Source urlSource = audio.UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      print("error playing recording: $e");
    }
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 500,
          width: 600,
          child: Column(
            children: [
              if (isRecording)
                const Text(
                  "Recording in progress",
                  style: TextStyle(fontSize: 22),
                ),
              ElevatedButton(
                onPressed: isRecording ? stopRecording : startRecording,
                child: isRecording
                    ? const Text('Stop Recording')
                    : const Text('Start Recording'),
              ),
              const SizedBox(
                height: 60,
              ),
              if (!isRecording && audioPath != null)
                ElevatedButton(
                  onPressed: playRecording,
                  child: const Text('Play Recording'),
                ),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) {
                  final position = Duration(seconds: value.toInt());
                  audioPlayer.seek(position);
                  audioPlayer.resume();
                },
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position.inSeconds)),
                    Text(formatTime((duration - position).inSeconds)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: IconButton(
                        onPressed: () {
                          if (isPlaying) {
                            audioPlayer.pause();
                          } else {
                            playRecording();
                          }
                        },
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
                  ),
                  CircleAvatar(
                    radius: 25,
                    child: IconButton(
                        onPressed: () {
                          audioPlayer.stop();
                        },
                        icon: const Icon(Icons.stop)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
