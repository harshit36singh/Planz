import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planz/providers/task_provider.dart';
import 'package:planz/providers/theme_provider.dart';
import 'package:planz/providers/user_provider.dart';
import 'package:planz/router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final active = ref.watch(activeTasksProvider);
    final completed = active.where((t) => t.isCompleted).length;
    final textColor = AppTheme.getTextColor(context);

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  "PROFILE",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // Profile card
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.getBorderColor(context),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$completed of ${active.length} tasks completed",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditNameDialog(context, ref, name),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _sectionTitle(context, "Settings"),
              _buildSettingsToggle(
                context,
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                subtitle: "Switch to dark theme",
                value: isDark,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  ref.read(themeProvider.notifier).setDarkMode(value);
                },
              ),

              _sectionTitle(context, "App"),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: "Help",
                subtitle: "Voice commands and tips",
                onTap: () => _showHelpSheet(context),
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: "About",
                subtitle: "App version and information",
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: "Planz",
                  applicationVersion: "1.0.0",
                  applicationLegalese:
                      "An offline task planner. All data stays on this device.",
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.restart_alt,
                title: "Reset App",
                subtitle: "Erase all tasks and your profile",
                isDestructive: true,
                onTap: () => _showResetSheet(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextColor(context),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    bool isDestructive = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDestructive
              ? Colors.red.shade600
              : AppTheme.getSecondaryTextColor(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? Colors.red.shade600
                      : AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildSettingsToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: _tile(
        context,
        icon: icon,
        title: title,
        subtitle: subtitle,
        trailing: Switch.adaptive(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Material(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
                width: 1,
              ),
            ),
            child: _tile(
              context,
              icon: icon,
              title: title,
              subtitle: subtitle,
              isDestructive: isDestructive,
              trailing: Icon(
                Icons.chevron_right,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Your name"),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: "What's your name?"),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null) {
      await ref.read(userProvider.notifier).rename(newName);
    }
  }

  void _showHelpSheet(BuildContext context) {
    const examples = [
      "Buy groceries",
      "Remind me to call mom tomorrow at 6 pm",
      "Schedule dentist appointment on Friday at 10:30 am",
      "Submit report on December 15",
      "Team meeting next week",
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getCardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tips",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "• Tap a task's circle to mark it complete\n"
                "• Tap a task on Home to edit it\n"
                "• Swipe a task left to move it to the trash\n"
                "• Restore or permanently delete from the trash icon on Home",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Voice command examples",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              for (final e in examples)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "“$e”",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(sheetContext),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restart_alt,
                size: 32,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Reset Planz?",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(sheetContext),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "All tasks (including the trash) and your name will be erased from this device. This cannot be undone.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        ref.read(taskProvider.notifier).clearAll();
                        await ref.read(userProvider.notifier).reset();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Approuter.landing,
                          (_) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Erase'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
