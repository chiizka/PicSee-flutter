import 'package:flutter/material.dart';
import 'package:picsee/gallery.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState() {
    super.initState();
    _initPermission();
  }

  Future<void> _initPermission() async {
    var status = await Permission.storage.status;

    if (status.isPermanentlyDenied) {
      _showPermissionSettingDialog();
      await Future.delayed(Duration(seconds: 3));
      openAppSettings();
      FlutterExitApp.exitApp();
    } else {
      status = await Permission.storage.request();
      if (status.isGranted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Gallery()),
        );
      } else {
        _showGoodbyeDialog();
      }
    }
  }

  void _showGoodbyeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Goodbye'),
        content: Text('Permission denied. Exiting the app.'),
        actions: [
          TextButton(
            onPressed: () {
              FlutterExitApp.exitApp();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text('Permission'),
          content: Text(
              'Permission denied. Allow permision storage access on app setting.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
