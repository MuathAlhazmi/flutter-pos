import 'package:flutter/material.dart';
import 'package:posapp/snackbar.dart';

import './bottom_navbar.dart';
import './item_list.dart';
import '../../provider/src.dart';
import '../../theme/rally.dart';

class DetailsScreen extends StatelessWidget {
  final TableModel order;
  final String? fromHeroTag;
  final String fromScreen;

  DetailsScreen(this.order, {this.fromHeroTag, required this.fromScreen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavBar(order, fromScreen: fromScreen, fromHeroTag: fromHeroTag),
      floatingActionButton: fromScreen == 'history'
          ? FloatingActionButton(
              onPressed: () {
                order.checkoutPrintClear(context: context);
                snackBarWidget(context, 'لم بتم إضافة الخاصية بعد', Icons.error, Colors.white);
                Navigator.pop(context);
              },
              elevation: 4.0,
              backgroundColor: RallyColors.primaryColor,
              child: Icon(
                Icons.print_sharp,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ItemList(order, fromScreen: fromScreen),
    );
  }
}
