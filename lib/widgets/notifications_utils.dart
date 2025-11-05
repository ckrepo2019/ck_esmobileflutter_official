// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:portal/main.dart';

// Future<void> showNotification() async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'your_channel_id',
//     'your_channel_name',
//     channelDescription: 'Your channel description',
//     importance: Importance.max,
//     priority: Priority.high,
//     ticker: 'ticker',
//   );

//   const NotificationDetails platformChannelSpecifics = NotificationDetails(
//     android: androidPlatformChannelSpecifics,
//   );

//   await flutterLocalNotificationsPlugin.show(
//     0,
//     'New Notification',
//     'You have a new notification!',
//     platformChannelSpecifics,
//     payload: 'notifications_screen',
//   );
// }
