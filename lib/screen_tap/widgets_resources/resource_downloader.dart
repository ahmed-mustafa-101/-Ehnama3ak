import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ehnama3ak/features/resources/data/models/resource_model.dart';
import 'local_downloads_manager.dart';

class ResourceDownloader {
  static Future<void> download(BuildContext context, ResourceModel resource) async {
    if (resource.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No content available')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${resource.title}...')),
    );
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      String ext = '';
      if (resource.url.contains('.')) {
        ext = resource.url.split('.').last.split('?').first;
      }
      final extensionSuffix = ext.isNotEmpty && ext.length < 5 ? '.$ext' : '';
      final fileName = '${resource.id}_${DateTime.now().millisecondsSinceEpoch}$extensionSuffix';
      final savePath = '${dir.path}/$fileName';
      
      await Dio().download(resource.url, savePath);
      await LocalDownloadsManager.saveDownloadedResource(resource, savePath);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloaded successfully to Downloads Tab')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    }
  }
}
