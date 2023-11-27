import 'package:flutter/material.dart';
import 'package:number_puzzles/providers/sound_provider.dart';
import 'package:number_puzzles/utils/launch_url.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 400,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  top: BorderSide(
                    width: 2,
                    color: Colors.red,
                  ),
                  bottom: BorderSide(
                    width: 2,
                    color: Colors.red,
                  ),
                  left: BorderSide(
                    width: 2,
                    color: Colors.red,
                  ),
                  right: BorderSide(
                    width: 2,
                    color: Colors.red,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.settings,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Consumer<AudioProvider>(
                    builder: (context, music, _) => SwitchListTile(
                      title: const Text('Music'),
                      value: music.isMusicTurnedOn,
                      onChanged: (value) {
                        if (value) {
                          music.musicPlayingTrue();
                          music.playMusic();
                        } else {
                          music.musicPlayingFalse();
                          music.stopMusic();
                        }
                      },
                    ),
                  ),
                  Consumer<AudioProvider>(
                    builder: (context, music, _) => SwitchListTile(
                      title: const Text('Sounds'),
                      value: music.isSoundTurnedOn,
                      onChanged: (value) {
                        if (value) {
                          music.switchIsSounsPlaying();
                        } else {
                          music.switchIsSounsPlaying();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          openUrl('https://raihansk.com/number-puzzles/');
                        },
                        child: const Text(
                          'About',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          openUrl('https://raihansk.com/contact/');
                        },
                        child: const Text(
                          'Contact',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          openUrl(
                              'https://raihansk.com/number-puzzles/privacy-policy-2/');
                        },
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          openUrl(
                              'https://raihansk.com/number-puzzles/terms-of-service/');
                        },
                        child: const Text(
                          'Terms',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
