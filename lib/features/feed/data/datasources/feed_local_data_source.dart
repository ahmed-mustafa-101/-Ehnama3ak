import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

class FeedLocalDataSource {
  static const String _postsCacheKey = 'CACHED_POSTS';
  final SharedPreferences _prefs;

  FeedLocalDataSource(this._prefs);

  Future<void> cachePosts(List<PostModel> posts) async {
    final String jsonString = jsonEncode(
      posts.map((post) => post.toJson()).toList(),
    );
    await _prefs.setString(_postsCacheKey, jsonString);
  }

  Future<List<PostModel>> getCachedPosts() async {
    final String? jsonString = _prefs.getString(_postsCacheKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> clearCache() async {
    await _prefs.remove(_postsCacheKey);
  }
}
