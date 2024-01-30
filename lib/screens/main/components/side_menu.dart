import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  
  const SideMenu({
    Key? key, required this.selectedIndex, required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => onItemSelected(0),
            selectedIndex: selectedIndex == 0,
          ),
          DrawerListTile(
            title: "Calendar",
            svgSrc: "assets/icons/calendar.svg",
            press: () => onItemSelected(1),
            selectedIndex: selectedIndex == 1,
          ),
          DrawerListTile(
            title: "Tasks",
            svgSrc: "assets/icons/tasks1.svg",
            press: () => onItemSelected(2),
            selectedIndex: selectedIndex == 2,
          ),
          DrawerListTile(
            title: "Employers",
            svgSrc: "assets/icons/employee.svg",
            press: () => onItemSelected(3),
            selectedIndex: selectedIndex == 3,
          ),
          DrawerListTile(
            title: "Upsells",
            svgSrc: "assets/icons/menu_store.svg",
            press: () => onItemSelected(4),
            selectedIndex: selectedIndex == 4,
          ),
          DrawerListTile(
            title: "Reservations",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () => onItemSelected(5),
            selectedIndex: selectedIndex == 5,
          ),
          DrawerListTile(
            title: "Communications",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () => onItemSelected(6),
            selectedIndex: selectedIndex == 6,
          ),
          DrawerListTile(
            title: "Support",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () => onItemSelected(7),
            selectedIndex: selectedIndex == 7,
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () => onItemSelected(8),
            selectedIndex: selectedIndex == 8,
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.selectedIndex
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: selectedIndex ? Border(left: BorderSide(width: 5, color: Colors.white)) : null,
      ),
      child: ListTile(
        onTap: press,
        horizontalTitleGap: 0.0,
        leading: SvgPicture.asset(
          svgSrc,
          colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
          height: 16,
        ),
        selected: selectedIndex,
        title: Text(
          title,
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
