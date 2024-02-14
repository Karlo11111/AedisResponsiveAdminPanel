import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/Authentication/authentiation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class CheckedInHeader extends StatefulWidget {
  final String CheckedInHeaderName;
  const CheckedInHeader({Key? key, required this.CheckedInHeaderName})
      : super(key: key);

  @override
  State<CheckedInHeader> createState() => _CheckedInHeaderState();
}

class _CheckedInHeaderState extends State<CheckedInHeader> {
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
              widget.CheckedInHeaderName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
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
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
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
                  child: Text("Karlo Ciciliani")),
            ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
