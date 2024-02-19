import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class ActivityOverviewCard extends StatelessWidget {
  const ActivityOverviewCard({
    Key? key,
    required this.title,
    required this.svgSrc,
  }) : super(key: key);

  final String title, svgSrc;

  @override
  Widget build(BuildContext context) {
    Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? lightTextColor
        : lightTextColor;
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: SvgPicture.asset(svgSrc),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: mainPrimaryTextColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
