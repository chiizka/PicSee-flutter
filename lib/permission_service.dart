import 'package:flutter/material.dart';
import 'package:picsee/gallery.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
    bool permissionStatus;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      permissionStatus = await Permission.photos.request().isGranted;
      var ispermanentdenied = await Permission.photos.status;

      if (ispermanentdenied.isPermanentlyDenied) {
        _showPermissionSettingDialog();
        await Future.delayed(Duration(seconds: 3));
        openAppSettings();
        FlutterExitApp.exitApp();
      } else {
        permissionStatus = await Permission.photos.request().isGranted;
        if (permissionStatus) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Gallery()),
          );
        } else {
          _showGoodbyeDialog();
        }
      }
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
      var ispermanentdenied = await Permission.storage.status;

      if (ispermanentdenied.isPermanentlyDenied) {
        _showPermissionSettingDialog();
        await Future.delayed(Duration(seconds: 3));
        openAppSettings();
        FlutterExitApp.exitApp();
      } else {
        permissionStatus = await Permission.storage.request().isGranted;
        if (permissionStatus) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Gallery()),
          );
        } else {
          _showGoodbyeDialog();
        }
      }
    }
  }

  void _navigateToGallery() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Gallery()),
    );
  }

  void _showGoodbyeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Goodbye'),
        content: Text('Permission denied. Exiting the app uwu.'),
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
        title: Text('Permission Required'),
        content: Text('Please grant storage permission to use the app.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Screen'),
      ),
      body: Center(
        child:
            CircularProgressIndicator(), // Add a loading indicator while checking permissions
      ),
    );
  }
}
