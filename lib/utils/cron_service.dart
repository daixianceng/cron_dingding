import 'dart:convert';
import 'package:cron/cron.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'utils.dart';

class CronService {
  static Cron? _cron;
  static SharedPreferences? _storage;

  static Future<List<TaskModel>?> init() async {
    _storage = await SharedPreferences.getInstance();
    return await retrieve();
  }

  static void register(List<TaskModel> tasks, {BuildContext? context}) {
    _cron = Cron();
    tasks.where((TaskModel t) => t.active).forEach((TaskModel t) {
      _cron!.schedule(Schedule.parse(t.schedule), () async {
        Application? app = await DeviceApps.getApp(DINGDING_PACKAGE_NAME);
        if (app == null) {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('未安装“钉钉”'),
              ),
            );
          }
        } else {
          await app.openApp();
        }
      });
    });
  }

  static Future<void> destroy() async {
    if (_cron != null) {
      await _cron!.close();
      _cron = null;
    }
  }

  static replace(List<TaskModel> tasks, {BuildContext? context}) async {
    await destroy();
    register(tasks, context: context);
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已应用新的更改'),
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
    preserve(tasks);
  }

  static Future<bool> preserve(List<TaskModel> tasks) async {
    return await _storage!
        .setString('tasks', jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }

  static Future<List<TaskModel>?> retrieve() async {
    try {
      bool hasKey = _storage!.containsKey('tasks');
      if (hasKey) {
        String data = _storage!.getString('tasks') as String;
        return (jsonDecode(data) as List)
            .map<TaskModel>((e) => TaskModel.fromJson(e))
            .toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
