import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<bool> requestPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<bool> isPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("Permission granted");
      } else {
        print("Permission denied");
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}