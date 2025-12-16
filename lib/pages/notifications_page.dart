import 'package:admin_panel/widgets/add_button.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/components/AddNotificationPopup.dart';
import 'package:admin_panel/widgets/EditNotificationPopup.dart';
import 'package:admin_panel/core/config.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      setState(() => isLoading = true);
      final res = await AppConfig.supabase
          .from("notifications")
          .select()
          .order("created_at", ascending: false);
      setState(() => notifications = res);
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await AppConfig.supabase.from("notifications").delete().eq("id", id);
      fetchNotifications();
    } catch (e) {
      debugPrint("Delete notification error: $e");
    }
  }

  void openAddPopup() {
    showDialog(
      context: context,
      builder:
          (_) => AddNotificationPopup(
            onSaved: fetchNotifications, // refresh after adding
          ),
    );
  }

  void openEditPopup(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder:
          (_) => EditNotificationPopup(
            notificationData: notification, // prefill fields
            onSaved: fetchNotifications, // refresh after editing
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notifications",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AddButton(label: "Add Notification", onPressed: openAddPopup),
            ],
          ),
          const SizedBox(height: 20),

          // List
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifications.isEmpty
                    ? const Center(
                      child: Text(
                        "No notifications found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children:
                            notifications.map((n) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    // Title
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        n["title"] ?? "-",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Description
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        n["description"] ?? "-",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    // Send Date
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        n["created_at"] != null
                                            ? n["created_at"]
                                                .toString()
                                                .substring(0, 10)
                                            : "-",
                                        style: const TextStyle(
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ),
                                    // Edit Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () => openEditPopup(n),
                                    ),
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed:
                                          () => deleteNotification(n["id"]),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
