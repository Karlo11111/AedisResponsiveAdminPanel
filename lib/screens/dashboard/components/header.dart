import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/Authentication/authentiation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatefulWidget {
  final String headerName;
  const Header({Key? key, required this.headerName}) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),
          if (!Responsive.isMobile(context))
            Text(
              widget.headerName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
          Expanded(child: SearchField()),
          ProfileCard()
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? secondaryColor
        : lightSecondaryColor;
    Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? lightTextColor
        : lightTextColor;


    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          //PROFILE PICTURE
          if (!Responsive.isMobile(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthenticationScreen(),
                        ));
                  },
                  child: Text("Karlo Ciciliani",
                      style: TextStyle(color: mainPrimaryTextColor))),
            ),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: mainPrimaryTextColor,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthenticationScreen(),
                  ));
            },
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchField({
    Key? key,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? secondaryColor
        : lightSecondaryColor;

    Color mainPrimaryColor = Theme.of(context).brightness == Brightness.dark
        ? primaryColor
        : lightPrimaryColor;

    return TextField(
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: backgroundColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {
            onChanged!(controller!.text);
          },
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: mainPrimaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(Icons.search), // Changed to Icon for simplicity
          ),
        ),
      ),
    );
  }
}
