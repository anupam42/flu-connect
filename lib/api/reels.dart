import 'dart:developer';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../config/cache_config.dart';

class ReelService {
// Here, I use some stock videos as an example.
// But you need to make this list empty when you will call api for your reels
  final _reels = <String>[
    'https://assets.mixkit.co/videos/4702/4702-720.mp4',
    'https://video-previews.elements.envatousercontent.com/files/48d99c34-537e-4a15-aac7-1b7353993096/video_preview_h264.mp4',
  ];

  Future getVideosFromApI() async {
    // call your api here
    // then add all links to _reels variable
    for (var i = 0; i < _reels.length; i++) {
      cacheVideos(_reels[i], i);
      // you can add multiple logic for to cache videos. Right now I'm caching all videos
    }
  }

  cacheVideos(String url, int i) async {
    FileInfo? fileInfo = await kCacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      log('downloading file ##------->$url##');
      await kCacheManager.downloadFile(url);
      log('downloaded file ##------->$url##');
      if (i + 1 == _reels.length) {
        log('caching finished');
      }
    }
  }

  List<String> getReels() {
    return _reels;
  }
}