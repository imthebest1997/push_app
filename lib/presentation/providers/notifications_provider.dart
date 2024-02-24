import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final notificationsProvider = StateNotifierProvider<NotificationsProvider, NotificationsState>((ref) {
  final provider = NotificationsProvider();
  provider._onForegroundMessage();
  provider._initialStatusCheck();
  return provider;
});


class NotificationsProvider extends StateNotifier<NotificationsState> {
  NotificationsProvider() : super(const NotificationsState());

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final notification = PushMessage(
      messageId: message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
          ? message.notification!.android?.imageUrl
          : message.notification!.apple?.imageUrl,
    );

    state = state.copyWith(notifications: [notification, ...state.notifications]);
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {
    final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    state = state.copyWith(status: settings.authorizationStatus);
  }

  void _initialStatusCheck() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    state = state.copyWith(status: settings.authorizationStatus);
  }
}



class NotificationsState {
  final AuthorizationStatus status;
  final List<PushMessage> notifications;

  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined,
    this.notifications = const [],
  });

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<PushMessage>? notifications,
  }) =>
    NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
    );
}

