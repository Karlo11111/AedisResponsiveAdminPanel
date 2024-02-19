import 'package:admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? secondaryColor
        : lightSecondaryColor;

    
    return Drawer(
      backgroundColor: backgroundColor,
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
            title: "Checked In Guests",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () => onItemSelected(5),
            selectedIndex: selectedIndex == 5,
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
            title: "Service Reservations",
            svgSrc: "assets/icons/menu_store.svg",
            press: () => onItemSelected(4),
            selectedIndex: selectedIndex == 4,
          ),
          
          SupportDrawerListTile(
            title: "Support",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () => onItemSelected(6),
            selectedIndex: selectedIndex == 6,
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
    Color mainPrimaryColor = Theme.of(context).brightness == Brightness.dark
        ? primaryColor
        : lightPrimaryColor;

    Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? lightTextColor
        : lightTextColor;
    return Container(
      decoration: BoxDecoration(
        border: selectedIndex ? Border(left: BorderSide(width: 5, color: Colors.white)) : null,
      ),
      child: ListTile(
        onTap: press,
        horizontalTitleGap: 0.0,
        leading: SvgPicture.asset(
          svgSrc,
          colorFilter: ColorFilter.mode(mainPrimaryColor, BlendMode.srcIn),
          height: 16,
        ),
        selected: selectedIndex,
        title: Text(
          title,
          style: TextStyle(color: mainPrimaryTextColor),
        ),
      ),
    );
  }
}

class SupportDrawerListTile extends StatelessWidget {
  const SupportDrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.selectedIndex,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool selectedIndex;

  @override
  Widget build(BuildContext context) {
    
    Color mainPrimaryColor = Theme.of(context).brightness == Brightness.dark
        ? primaryColor
        : lightPrimaryColor;

    Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? lightTextColor
        : lightTextColor;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Help').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(title),
            leading: CircularProgressIndicator(),
          );
        }

        // Assuming you want to count the number of documents in the 'Help' collection
        int documentCount = snapshot.data?.docs.length ?? 0;

        return Container(
          decoration: BoxDecoration(
            border: selectedIndex
                ? Border(left: BorderSide(width: 5, color: Colors.white))
                : null,
          ),
          child: ListTile(
            onTap: press,
            horizontalTitleGap: 0.0,
            leading: SvgPicture.asset(
              svgSrc,
              colorFilter: ColorFilter.mode(mainPrimaryColor, BlendMode.srcIn),
              height: 16,
            ),
            selected: selectedIndex,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: mainPrimaryTextColor),
                ),
                SizedBox(
                  width: 15,
                ),
                if (documentCount > 0)
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: mainPrimaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$documentCount',
                      style: TextStyle(
                        color: mainPrimaryTextColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
