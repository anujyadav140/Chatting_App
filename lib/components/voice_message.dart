import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({super.key});

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String audioPath = '';
  late Source urlSource;
  late String recordingUrl;
  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audioRecord = Record();

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
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
    audioRecord.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    print("hello");
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print("error recording stuff: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
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
      Source urlSource = UrlSource(audioPath);
      if (isAndroid()) {
        await audioPlayer.play(urlSource);
      } else {
      }
    } catch (e) {
      print("error playing recording: $e");
    }
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  bool isAndroid() {
    if (kIsWeb) {
      // Running on the web
      return false;
    } else {
      // Running on Android
      return true;
    }
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
