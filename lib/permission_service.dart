import 'package:flutter/material.dart';
import 'package:picsee/home_screen.dart';
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
    _initGallery();
  }

  Future<void> _initGallery() async {
    // Check if storage permission is granted
    final hasPermission = await PermissionService.hasStoragePermission();

    if (await PermissionService.checkPermanentlyDenied()) {
      // Show a permission dialog and go to the app permission settings
      _showPermissionSettingDialog();
      await Future.delayed(Duration(seconds: 3));
      PermissionService.openSettings();
      FlutterExitApp.exitApp();
    } else {
      if (!hasPermission) {
        // If not granted, request permission
        final granted = await PermissionService.requestStoragePermission();

        if (!granted) {
          // Show a goodbye dialog and exit the app
          _showGoodbyeDialog();
        }
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Center(),
    );
  }
}

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    final permission = Permission.storage;

    if (await permission.isDenied) {
      await permission.request();
    }
    return permission.status.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    final permission = Permission.storage;

    return permission.status.isGranted;
  }

  static Future<bool> checkPermanentlyDenied() async {
    final permission = Permission.storage;

    return await permission.status.isPermanentlyDenied;
  }

  static Future<void> openSettings() async {
    openAppSettings();
  }
}
