import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.storage.request();
      return status.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    
    return false;
  }

  static Future<bool> requestManageExternalStorage() async {
    if (await Permission.manageExternalStorage.isDenied) {
      PermissionStatus status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    
    return await Permission.manageExternalStorage.isGranted;
  }

  static Future<bool> requestAllStoragePermissions() async {
    bool storagePermission = await requestStoragePermission();
    bool managePermission = await requestManageExternalStorage();
    
    return storagePermission || managePermission;
  }
}