import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehnama3ak/features/resources/data/models/resource_model.dart';

class LocalDownloadsManager {
  static const _key = 'downloaded_resources';

  static Future<void> saveDownloadedResource(ResourceModel resource, String localPath) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    
    final map = resource.toJson();
    map['url'] = localPath; // Store local path instead of remote url
    
    bool exists = false;
    for (int i = 0; i < list.length; i++) {
      final decoded = jsonDecode(list[i]);
      if (decoded['id'] == resource.id) {
        list[i] = jsonEncode(map);
        exists = true;
        break;
      }
    }
    if (!exists) {
      list.add(jsonEncode(map));
    }
    
    await prefs.setStringList(_key, list);
  }

  static Future<List<ResourceModel>> getDownloadedResources() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => ResourceModel.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> removeDownloadedResource(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((e) => jsonDecode(e)['id'] == id);
    await prefs.setStringList(_key, list);
  }
}
