import '../core/config.dart';
import '../models/app_user.dart';

class UserService {
  static Future<AppUser?> getCurrentUser() async {
    final authUser = AppConfig.supabase.auth.currentUser;
    if (authUser == null) return null;

    final res =
        await AppConfig.supabase
            .from('users')
            .select()
            .eq('id', authUser.id)
            .single();

    return AppUser.fromMap(res);
  }
}
