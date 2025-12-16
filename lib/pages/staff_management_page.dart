import 'package:admin_panel/widgets/staff_tile.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/staff_service.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  bool loading = true;
  List<AppUser> staff = [];

  @override
  void initState() {
    super.initState();
    loadStaff();
  }

  Future<void> loadStaff() async {
    final res = await StaffService.fetchStaff();
    if (mounted) {
      setState(() {
        staff = res;
        loading = false;
      });
    }
  }

  Future<void> toggleStatus(AppUser user) async {
    final newStatus = user.status == 'active' ? 'disabled' : 'active';
    await StaffService.updateStatus(userId: user.id, status: newStatus);
    loadStaff();
  }

  Future<void> deleteUser(AppUser user) async {
    await StaffService.deleteStaff(user.id);
    loadStaff();
  }

  void showCreateStaffDialog() {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Text(
              "Create Staff",
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await StaffService.createStaff(
                    email: emailCtrl.text,
                    password: passCtrl.text,
                    fullName: nameCtrl.text,
                  );
                  Navigator.pop(context);
                  loadStaff();
                },
                child: const Text("Create"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateStaffDialog,
        child: const Icon(Icons.add),
      ),

      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : staff.isEmpty
              ? const Center(
                child: Text(
                  "No staff found",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: staff.length,
                separatorBuilder:
                    (_, __) => const Divider(color: Colors.white12),
                itemBuilder: (_, i) {
                  final user = staff[i];
                  return StaffTile(
                    user: user,
                    onToggle: () => toggleStatus(user),
                    onDelete: () => deleteUser(user),
                  );
                },
              ),
    );
  }
}
