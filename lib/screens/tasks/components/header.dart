import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasksHeader extends StatelessWidget {
  const TasksHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // This IconButton should be shown for both mobile and tablet, but not for desktop.
          if (!Responsive.isDesktop(context))
            IconButton(
              padding: const EdgeInsets.all(defaultPadding),
              icon: const Icon(Icons.menu),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),
          // This condition ensures that "Tasks" text is shown for tablet and desktop, but not for mobile.
          if (!Responsive.isMobile(context) || Responsive.isTablet(context))
            Text(
              "Tasks",
              style: Theme.of(context).textTheme.titleLarge,
            ),
        ],
      ),
    );
  }
}
