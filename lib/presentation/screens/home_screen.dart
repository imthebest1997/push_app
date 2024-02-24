import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/providers/notifications_provider.dart';

class HomeScreen extends ConsumerWidget {
   
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.watch(notificationsProvider).status.toString()),
        actions: [
          IconButton(
            onPressed: (){
              ref.read(notificationsProvider.notifier).requestPermission();
            }, 
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: const _HomeView(),
    );
  }
}

class _HomeView extends ConsumerWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return ListView.builder(
      itemCount: notifications.notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications.notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.body),
          leading: notification.imageUrl != null ? Image.network(notification.imageUrl!) : null,
          onTap: () => context.push("/push-details/${notification.messageId}"),
        );
      },
    );
  }
}