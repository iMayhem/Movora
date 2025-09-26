import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movora/models/media.dart';

class StorageService {
  static const String _likedVideosKey = 'liked_videos';
  static const String _myListKey = 'my_list';

  /// Get liked videos
  static Future<List<Media>> getLikedVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedJson = prefs.getString(_likedVideosKey);

      if (likedJson == null) return [];

      final List<dynamic> likedList = json.decode(likedJson);
      return likedList.map((json) => Media.fromJson(json)).toList();
    } catch (e) {
      print('Error getting liked videos: $e');
      return [];
    }
  }

  /// Add video to liked list
  static Future<bool> addToLikedVideos(Media media) async {
    try {
      final likedVideos = await getLikedVideos();

      // Check if already liked
      if (likedVideos.any((video) => video.id == media.id)) {
        return false; // Already liked
      }

      likedVideos.add(media);
      final prefs = await SharedPreferences.getInstance();
      final likedJson =
          json.encode(likedVideos.map((video) => video.toJson()).toList());

      return await prefs.setString(_likedVideosKey, likedJson);
    } catch (e) {
      print('Error adding to liked videos: $e');
      return false;
    }
  }

  /// Remove video from liked list
  static Future<bool> removeFromLikedVideos(int mediaId) async {
    try {
      final likedVideos = await getLikedVideos();
      likedVideos.removeWhere((video) => video.id == mediaId);

      final prefs = await SharedPreferences.getInstance();
      final likedJson =
          json.encode(likedVideos.map((video) => video.toJson()).toList());

      return await prefs.setString(_likedVideosKey, likedJson);
    } catch (e) {
      print('Error removing from liked videos: $e');
      return false;
    }
  }

  /// Check if video is liked
  static Future<bool> isLiked(int mediaId) async {
    try {
      final likedVideos = await getLikedVideos();
      return likedVideos.any((video) => video.id == mediaId);
    } catch (e) {
      print('Error checking if liked: $e');
      return false;
    }
  }

  /// Get my list videos
  static Future<List<Media>> getMyList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final myListJson = prefs.getString(_myListKey);

      if (myListJson == null) return [];

      final List<dynamic> myList = json.decode(myListJson);
      return myList.map((json) => Media.fromJson(json)).toList();
    } catch (e) {
      print('Error getting my list: $e');
      return [];
    }
  }

  /// Add video to my list
  static Future<bool> addToMyList(Media media) async {
    try {
      final myList = await getMyList();

      // Check if already in list
      if (myList.any((video) => video.id == media.id)) {
        return false; // Already in list
      }

      myList.add(media);
      final prefs = await SharedPreferences.getInstance();
      final myListJson =
          json.encode(myList.map((video) => video.toJson()).toList());

      return await prefs.setString(_myListKey, myListJson);
    } catch (e) {
      print('Error adding to my list: $e');
      return false;
    }
  }

  /// Remove video from my list
  static Future<bool> removeFromMyList(int mediaId) async {
    try {
      final myList = await getMyList();
      myList.removeWhere((video) => video.id == mediaId);

      final prefs = await SharedPreferences.getInstance();
      final myListJson =
          json.encode(myList.map((video) => video.toJson()).toList());

      return await prefs.setString(_myListKey, myListJson);
    } catch (e) {
      print('Error removing from my list: $e');
      return false;
    }
  }

  /// Check if video is in my list
  static Future<bool> isInMyList(int mediaId) async {
    try {
      final myList = await getMyList();
      return myList.any((video) => video.id == mediaId);
    } catch (e) {
      print('Error checking if in my list: $e');
      return false;
    }
  }

  /// Get count of liked videos
  static Future<int> getLikedCount() async {
    final likedVideos = await getLikedVideos();
    return likedVideos.length;
  }

  /// Get count of my list videos
  static Future<int> getMyListCount() async {
    final myList = await getMyList();
    return myList.length;
  }
}
