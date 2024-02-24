import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        return ListTile(
          title: Text(notifications.notifications[index].title),
          subtitle: Text(notifications.notifications[index].body),
          leading: notifications.notifications[index].imageUrl != null ? Image.network(notifications.notifications[index].imageUrl!) : null,
        );
      },
    );
  }
}