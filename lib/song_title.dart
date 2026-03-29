import 'package:flutter/material.dart';
import 'package:melo/song_modele.dart';

class SongTitle extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onTap;

  SongTitle({required this.song, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPlaying ? Colors.purple : Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: isPlaying
            ? Border.all(color: Colors.deepPurple, width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,           
              end: Alignment.bottomRight,         
              colors: isPlaying
                  ? [Colors.purple, Colors.purple.shade700]
                  : [Colors.grey.shade800, Colors.grey.shade700],
            ),
          ),
          child: Icon(
            isPlaying ? Icons.music_note : Icons.music_note_outlined,
            color: Colors.white,
          ),
        ),                                       
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.artist.isNotEmpty ? song.artist : "Unknown Artist", 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            if (song.duration.inSeconds > 0)
              Text(
                _formatDuration(song.duration),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
          ],
        ),
        trailing: isPlaying
            ? Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2), 
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pause,
                  color: Colors.deepPurple,             
                  size: 20,
                ),
              )
            : Icon(Icons.play_arrow, color: Colors.grey),
        onTap: onTap,
      ),                                                  
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitsMinutes:$twoDigitsSeconds';
  }
}