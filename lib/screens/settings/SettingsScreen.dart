import 'package:admin/responsive.dart';
import 'package:admin/screens/settings/components/setting_switch.dart';
import 'package:admin/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Responsive.isDesktop(context)
            ? _buildDesktopLayout(context)
            : _buildMobileLayout(context),
      ),
    );
  }
}

Widget _buildMobileLayout(BuildContext context) {
  bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
  return Column(
    children: [
      // dark mode toggle
      SettingSwitch(
        value: isDarkMode,
        title: "Dark theme",
        icon: Icons.dark_mode,
        bgColor: Theme.of(context).colorScheme.secondary,
        iconColor: Theme.of(context).colorScheme.secondary,
        onTap: (value) {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        },
      ),
    ],
  );
}

Widget _buildDesktopLayout(BuildContext context) {
  bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

  return Row(
    children: [
      Expanded(
        // Wrap SettingSwitch with Expanded
        child: SettingSwitch(
          value: isDarkMode,
          title: "Dark theme",
          icon: Icons.dark_mode,
          bgColor: Theme.of(context).colorScheme.secondary,
          iconColor: Theme.of(context).colorScheme.secondary,
          onTap: (value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
      ),
    ],
  );
}
