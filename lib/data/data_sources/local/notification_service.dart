import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/theme/text_constants.dart';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
        android: androidInitializationSettings, iOS: iOSInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> showProgressNotification(
      int progress, int maxProgress, String fileName) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
      0,
      '${TextConstants.showDownloading} $fileName',
      '${(progress / maxProgress * 100).toStringAsFixed(0)}%',
      platformChannelSpecifics,
    );
  }

  Future<void> showCompletionNotification(String fileName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
      0,
      TextConstants.showDownloaded,
      '${TextConstants.textFile} $fileName',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> showErrorNotification(String fileName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
      0,
      TextConstants.showErrorDownload,
      '${TextConstants.textFile} $fileName',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
