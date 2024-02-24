import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //TODO: Implementar ISAR
}


class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super(const NotificationsState()) {
    on<NotificationStatusChanged>( _notificationsStatusChange );
    on<NotificationReceived>( _onPushMessageReceived );


    //Verificar el estado de las notificaciones
    _initialStatusCheck();
    // Manejar mensajes en primer plano
    _onForegroundMessage();
  }


  void _initialStatusCheck() async{
    final settings = await messaging.getNotificationSettings();
    settings.authorizationStatus == AuthorizationStatus.authorized
      ? add( NotificationStatusChanged(settings.authorizationStatus) )
      : requestPermissions(); 

    _getFirebaseToken();   
  }

  void _getFirebaseToken() async {
    if( state.status != AuthorizationStatus.authorized ) return;

    String? token = await messaging.getToken();
    print('Token: $token');
  }

  void handleRemoteMessage(RemoteMessage message){
    if(message.notification == null) return;

    final notification = PushMessage(
      messageId: message.messageId
        ?.replaceAll(":", "").replaceAll("%", "")
        ?? "", 
      title: message.notification?.title ?? "", 
      body: message.notification?.body ?? "",
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
        ? message.notification?.android?.imageUrl 
        : message.notification?.apple?.imageUrl
    );

    add(NotificationReceived(notification));
  }

  void _onForegroundMessage(){
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  PushMessage? getMessageById( String pushMessageId ) {
    final exist = state.notifications.any((element) => element.messageId == pushMessageId );
    if ( !exist ) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId );
  }

  void requestPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    add( NotificationStatusChanged(settings.authorizationStatus) );
  }

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationsStatusChange(NotificationStatusChanged event, Emitter<NotificationsState> emit){
    emit(
      state.copyWith(
        status: event.status,
      )
    );
    _getFirebaseToken();
  }

  void _onPushMessageReceived(NotificationReceived event, Emitter<NotificationsState> emit){
    emit(
      state.copyWith(
        notifications: [
          event.pushMessage,
          ...state.notifications
        ]
      )
    );
  }
}
