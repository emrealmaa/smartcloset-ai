import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/clothing_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../auth/login_screen.dart';

// ── Notification Settings Provider ───────────────────────────────
class NotificationSettings {
  final bool morningWeather;
  final bool outfitReminder;
  final bool newInspiration;
  final TimeOfDay reminderTime;

  const NotificationSettings({
    this.morningWeather = true,
    this.outfitReminder = false,
    this.newInspiration = true,
    this.reminderTime = const TimeOfDay(hour: 8, minute: 0),
  });

  NotificationSettings copyWith({
    bool? morningWeather,
    bool? outfitReminder,
    bool? newInspiration,
    TimeOfDay? reminderTime,
  }) =>
      NotificationSettings(
        morningWeather: morningWeather ?? this.morningWeather,
        outfitReminder: outfitReminder ?? this.outfitReminder,
        newInspiration: newInspiration ?? this.newInspiration,
        reminderTime: reminderTime ?? this.reminderTime,
      );
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      morningWeather: prefs.getBool('notif_morning') ?? true,
      outfitReminder: prefs.getBool('notif_outfit') ?? false,
      newInspiration: prefs.getBool('notif_inspiration') ?? true,
      reminderTime: TimeOfDay(
        hour: prefs.getInt('notif_hour') ?? 8,
        minute: prefs.getInt('notif_minute') ?? 0,
      ),
    );
  }

  Future<void> toggleMorningWeather(bool val) async {
    state = state.copyWith(morningWeather: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_morning', val);
  }

  Future<void> toggleOutfitReminder(bool val) async {
    state = state.copyWith(outfitReminder: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_outfit', val);
  }

  Future<void> toggleNewInspiration(bool val) async {
    state = state.copyWith(newInspiration: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_inspiration', val);
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    state = state.copyWith(reminderTime: time);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_hour', time.hour);
    await prefs.setInt('notif_minute', time.minute);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

// ── Profile Tab ───────────────────────────────────────────────────
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final countAsync = ref.watch(clothingCountProvider);
    final notifSettings = ref.watch(notificationSettingsProvider);

    final displayName = user?.displayName ?? 'Kullanıcı';
    final email = user?.email ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              _ProfileHeader(
                displayName: displayName,
                email: email,
                initial: initial,
              ),

              const SizedBox(height: 8),

              // ── İstatistikler ────────────────────────────────────
              _StatsRow(countAsync: countAsync),

              const SizedBox(height: 20),

              // ── Bildirimler ──────────────────────────────────────
              _SectionTitle('Bildirimler'),
              _NotificationSection(settings: notifSettings),

              const SizedBox(height: 20),

              // ── Hesap ─────────────────────────────────────────────
              _SectionTitle('Hesap'),
              _AccountSection(email: email),

              const SizedBox(height: 20),

              // ── Uygulama ──────────────────────────────────────────
              _SectionTitle('Uygulama'),
              _AppSection(),

              const SizedBox(height: 24),

              // ── Çıkış ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ScButton(
                  label: 'Çıkış Yap',
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  icon: Icons.logout_rounded,
                ),
              ),

              const SizedBox(height: 12),

              // Versiyon
              Center(
                child: Text(
                  'SmartCloset AI v1.0.0',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String initial;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.softGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.neonGreen.withOpacity(0.1),
              border: Border.all(
                color: AppTheme.neonGreen.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neonGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // İsim + mail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.neonGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_outlined,
                          size: 12, color: AppTheme.neonGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Ücretsiz Plan',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neonGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AsyncValue<int> countAsync;
  const _StatsRow({required this.countAsync});

  @override
  Widget build(BuildContext context) {
    final count = countAsync.valueOrNull ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softGray),
      ),
      child: Row(
        children: [
          _StatItem(value: '$count', label: 'Kıyafet'),
          _StatDivider(),
          _StatItem(value: '0', label: 'Kombin'),
          _StatDivider(),
          _StatItem(value: '0', label: 'İlham'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppTheme.softGray);
  }
}

// ── Section Title ─────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.mediumGray,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Notification Section ──────────────────────────────────────────
class _NotificationSection extends ConsumerWidget {
  final NotificationSettings settings;
  const _NotificationSection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsCard(
      children: [
        _ToggleRow(
          icon: Icons.wb_sunny_outlined,
          iconColor: const Color(0xFFF59E0B),
          title: 'Sabah Hava Durumu',
          subtitle: 'Her sabah kombin önerisi al',
          value: settings.morningWeather,
          onChanged: (v) => ref
              .read(notificationSettingsProvider.notifier)
              .toggleMorningWeather(v),
        ),
        _Separator(),
        _ToggleRow(
          icon: Icons.checkroom_outlined,
          iconColor: AppTheme.neonGreen,
          title: 'Kombin Hatırlatıcı',
          subtitle: _timeLabel(settings.reminderTime),
          value: settings.outfitReminder,
          onChanged: (v) => ref
              .read(notificationSettingsProvider.notifier)
              .toggleOutfitReminder(v),
          trailing: settings.outfitReminder
              ? GestureDetector(
                  onTap: () => _pickTime(context, ref, settings.reminderTime),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.softGray),
                    ),
                    child: Text(
                      _timeLabel(settings.reminderTime),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neonGreen,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        _Separator(),
        _ToggleRow(
          icon: Icons.auto_awesome_outlined,
          iconColor: const Color(0xFF8B5CF6),
          title: 'Yeni İlham',
          subtitle: 'Günlük yeni kombinler geldiğinde',
          value: settings.newInspiration,
          onChanged: (v) => ref
              .read(notificationSettingsProvider.notifier)
              .toggleNewInspiration(v),
        ),
      ],
    );
  }

  String _timeLabel(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(
      BuildContext context, WidgetRef ref, TimeOfDay current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.neonGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(notificationSettingsProvider.notifier).setReminderTime(picked);
    }
  }
}

// ── Account Section ───────────────────────────────────────────────
class _AccountSection extends StatelessWidget {
  final String email;
  const _AccountSection({required this.email});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        _NavRow(
          icon: Icons.person_outline,
          iconColor: const Color(0xFF3B82F6),
          title: 'Profili Düzenle',
          onTap: () => showScSnackbar(context, 'Yakında gelecek!'),
        ),
        _Separator(),
        _NavRow(
          icon: Icons.lock_outline,
          iconColor: const Color(0xFFF59E0B),
          title: 'Şifre Değiştir',
          onTap: () => showScSnackbar(context, 'Yakında gelecek!'),
        ),
        _Separator(),
        _NavRow(
          icon: Icons.mail_outline,
          iconColor: AppTheme.neonGreen,
          title: email,
          subtitle: 'Mail adresi',
          onTap: null,
        ),
      ],
    );
  }
}

// ── App Section ───────────────────────────────────────────────────
class _AppSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        _NavRow(
          icon: Icons.info_outline,
          iconColor: const Color(0xFF6B7280),
          title: 'Hakkında',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'SmartCloset AI',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2026 SmartCloset AI',
          ),
        ),
        _Separator(),
        _NavRow(
          icon: Icons.privacy_tip_outlined,
          iconColor: const Color(0xFF8B5CF6),
          title: 'Gizlilik Politikası',
          onTap: () => showScSnackbar(context, 'Yakında gelecek!'),
        ),
        _Separator(),
        _NavRow(
          icon: Icons.star_outline_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: 'Uygulamayı Değerlendir',
          onTap: () => showScSnackbar(context, 'Yakında gelecek!'),
        ),
      ],
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softGray),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 8),
          ],
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.neonGreen,
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _NavRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  color: AppTheme.mediumGray, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Divider(height: 1, color: AppTheme.softGray),
    );
  }
}
