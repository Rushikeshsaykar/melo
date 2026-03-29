import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melo/song_modele.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


class MusicService {

  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _songs = [];
  int _currentIndex = -1;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get songs => _songs;
  int get currentIndex => _currentIndex;
  Song? get currentSong => (_currentIndex >=0 && _currentIndex<_songs.length) ? _songs[_currentIndex] :null;

  // load songs into the service
  Future<List<Song>> scanForSongs() async {
    _songs.clear();
    try {
      final allDirectories = await _getAllStorageDirectories();
      for (String dirPath in allDirectories) {
        await _scanDirectoryRecursively(dirPath);
      }
      _songs = _removeDuplicates(_songs);
      _songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } catch (e) {
      print("error scanning for songs: $e");
    }
    return _songs;
  }

  Future<List<String>> _getAllStorageDirectories() async {
    List<String> directories = [];

    final primaryPaths = [
      '/storage/emulated/0',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Android/data',
      '/storage/emulated/0/Android/media',
      '/storage/emulated/0/media',
      '/storage/emulated/0/Audio',
      '/storage/emulated/0/Ringtones',
      '/storage/emulated/0/Alarms',
      '/sdcard',
    ];

    final secondaryPaths = [
      '/storage/emulated/1',
    ];

    directories.addAll(primaryPaths);
    directories.addAll(secondaryPaths);

    try {
      final storageDir = Directory("/storage");
      if (await storageDir.exists()) {
        await for (FileSystemEntity entity in storageDir.list(recursive: false)) {
          if (entity is Directory && !directories.contains(entity.path)) {
            directories.add(entity.path);
          }
        }
      }
    } catch (e) {
      print("error getting storage directory: $e");
    }

    List<String> existingDirs = [];
    for (String dir in directories) {
      try {
        final directory = Directory(dir);
        if (await directory.exists()) {
          existingDirs.add(dir);
        }
      } catch (e) {
        print("error checking directory $dir: $e");
        continue;
      }
    }
    return existingDirs;
  }

  Future<void> _scanDirectoryRecursively(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      await for (FileSystemEntity entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          try {
            final song = await _createSongFromFile(entity);
            if (song != null) {
              _songs.add(song);
            }
          } catch (e) {
            print("error processing file ${entity.path}: $e");
            continue;
          }
        }
      }
    } catch (e) {
      print("error scanning directory $dirPath: $e");
    }
  }

  bool _isAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    final audioExtensions = [
      '.mp3',
      '.wav',
      '.flac',
      '.aac',
      '.ogg',
      '.m4a',
      '.wma',
      '.opus',
    ];
    return audioExtensions.contains(extension);
  }

  Future<Song?> _createSongFromFile(File file) async {
    try {
      final fileName = path.basenameWithoutExtension(file.path);
      String title = fileName;
      String artist = "unknown artist";
      String album = "unknown album";
      Duration duration = Duration.zero;

      try {
        final tempPlayer = AudioPlayer();
        await tempPlayer.setFilePath(file.path);

        if (tempPlayer.duration != null) {
          duration = tempPlayer.duration!;
        }
        await tempPlayer.dispose();
      } catch (e) {
        if (fileName.contains("-")) {
          final parts = fileName.split("-");
          if (parts.length >= 2) {
            artist = parts[0].trim();
            title = parts.sublist(1).join(" - ").trim();
          }
        }
      }

      return Song(
        title: title,
        artist: artist,
        album: album,
        path: file.path,
        duration: duration,
      );
    } catch (e) {
      print("error creating song from file ${file.path}: $e");
      return null;
    }
  }

  List<Song> _removeDuplicates(List<Song> songs) {
    final seen = <String>{};
    return songs.where((song) {
      final key = '${song.title}-${song.artist}-${song.duration.inSeconds}';
      return seen.add(key);
    }).toList();
  }

  Future<void> playSong(int index) async {
    if (index >= 0 && index < _songs.length) {
      _currentIndex = index;
      await _audioPlayer.setFilePath(_songs[index].path);
      await _audioPlayer.play();
    }
  }

  Future<void> playPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> skipNext() async {
    if (_currentIndex < _songs.length - 1) {
      await playSong(_currentIndex + 1);
    } else {
      await playSong(0);
    }
  }

  Future<void> skipPrevious() async {
    if (_currentIndex > 0) {
      await playSong(_currentIndex - 1);
    } else {
      await playSong(_songs.length - 1);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void shufflePlaylist() {
    if (_songs.length > 1) {
      final currentSong = _songs[_currentIndex];
      _songs.shuffle();

      final newIndex = _songs.indexOf(currentSong);
      if (newIndex != _currentIndex) {
        final temp = _songs[_currentIndex];
        _songs[_currentIndex] = currentSong;
        _songs[newIndex] = temp;
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _songs.clear();
    _currentIndex = -1;
  }
}