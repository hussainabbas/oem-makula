import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        child: _tabBar,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(1),
          border: Border(
              bottom: BorderSide(
                  color: borderColor, width: 1)),
        )
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}