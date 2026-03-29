import 'package:flutter/material.dart';
import 'package:melo/music_screen.dart';
import 'package:melo/music_service.dart';
import 'package:melo/song_modele.dart';
import 'package:melo/song_title.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicService _musicService = MusicService();
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSong(); 
  }

  Future<void> _loadSong() async {
    setState(() {
      _isLoading = true;
    });
    _songs = await _musicService.scanForSongs();
    setState(() {
      _isLoading = false;
    });
  }

  void _onSongTap(int index) async {
    await _musicService.playSong(index);
    setState(() {});
  }

  void _openMusicScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MusicScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music Player"),
        actions: [
          IconButton(onPressed: _loadSong, icon: Icon(Icons.refresh)),
          IconButton(
            onPressed: () => _openMusicScreen(context),
            icon: Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          "Loading Songs..",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : _songs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.music_off, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No songs found",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16), // ✅ comma was missing here
                            ElevatedButton(
                              onPressed: _loadSong, // ✅ no parentheses
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple, // ✅ fixed typo
                                foregroundColor: Colors.white,
                              ),
                              child: Text("Scan Again"),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder( 
                        padding: EdgeInsets.all(16),
                        itemCount: _songs.length,
                        itemBuilder: (context, index) {
                          return SongTitle(
                            song: _songs[index],
                            isPlaying: _musicService.currentIndex == index, 
                            onTap: () => _onSongTap(index),
                          );
                        },
                      ),
          ),
         
        //  if(_musicService.currentSong !=null)
        //  miniplayer(
        //   onTap:_openMusicScreen,
        //   onplaypouse:()async{
        //     await _musicService.playPause();
        //     setState(() {
              
        //     });
        //   }
        //  )

        ],
      ),
    );
  }
}