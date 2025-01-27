import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import '../../theme/rally.dart';
import '../popup_del.dart';

class TableIcon extends StatelessWidget {
  final TableModel table;

  TableIcon({required this.table});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: _RadialButton(
        table,
        surroundingButtonsBuilder: (context, animController, angles) =>
            _build(context, animController, angles),
        displayAngles: [0, 90, 180],
      ),
    );
  }

  List<Widget> _build(
    BuildContext context,
    AnimationController radialAnimationController,
    List<double> angles,
  ) {
    return [
      // add order
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[0],
        key: ValueKey<int>(1),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: CupertinoColors.tertiarySystemFill,
          mini: true,
          heroTag: 'menu-subtag-table-${table.id}',
          onPressed: () {
            Navigator.pushNamed(context, '/menu', arguments: {
              'heroTag': 'menu-subtag-table-${table.id}',
              'model': table,
            }).then((_) {
              Future.delayed(
                Duration(milliseconds: 600),
                () => radialAnimationController.reverse(),
              );
            });
          },
          child: Icon(
            CupertinoIcons.add,
            color: radialAnimationController.value > 0 ? Colors.white : Colors.transparent,
          ),
        ),
      ),
      // see order details (and checkout)
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[1],
        key: ValueKey<int>(2),
        child: FloatingActionButton(
          elevation: 0,
          mini: true,
          heroTag: 'details-subtag-table-${table.id}',
          onPressed: table.status == TableStatus.occupied
              ? () {
                  Navigator.pushNamed(context, '/order-details', arguments: {
                    'heroTag': 'details-subtag-table-${table.id}',
                    'state': table,
                    'from': 'lobby',
                  }).then((_) {
                    Future.delayed(
                      Duration(milliseconds: 600),
                      () => radialAnimationController.reverse(),
                    );
                  });
                }
              : null,
          backgroundColor:
              table.status == TableStatus.occupied ? null : CupertinoColors.tertiarySystemFill,
          child: Icon(
            Icons.receipt_rounded,
            color: radialAnimationController.value > 0 ? Colors.white : Colors.transparent,
          ),
        ),
      ),
      // remove table node
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[2],
        key: ValueKey<int>(3),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: CupertinoColors.tertiarySystemFill,
          mini: true,
          heroTag: 'delete-subtag-table-${table.id}',
          onPressed: () => _removeTable(context, table.id),
          child: Icon(
            Icons.delete,
            color: radialAnimationController.value > 0 ? Colors.white : Colors.transparent,
          ),
        ),
      ),
    ];
  }
}

class _RadialButton extends StatelessWidget {
  final TableModel model;

  final List<Widget> Function(BuildContext, AnimationController, List<double> displayAngles)
      surroundingButtonsBuilder;

  /// Clock-wise placement angles for surrounding sub-buttons (add order, details...).
  /// Example: `[0, 90]` would place one at 3 o'clock, the other at 6 o'clock
  final List<double> displayAngles;

  _RadialButton(
    this.model, {
    required this.surroundingButtonsBuilder,
    required this.displayAngles,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _colorTween = ColorTween(
      begin: model.status == TableStatus.occupied
          ? RallyColors.primaryColor.withOpacity(.5)
          : model.status == TableStatus.incomplete
              ? CupertinoColors.tertiarySystemFill
              : CupertinoColors.tertiarySystemFill,
      end: RallyColors.focusColor,
    );

    return RadialMenu(
      closedBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          elevation: 0,
          heroTag: null,
          onPressed: () {
            radialAnimationController.forward();
          },
          backgroundColor: _colorTween.animate(radialAnimationController).value,
          child: Text(
            model.id.toString(),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      },
      openBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          onPressed: () {
            radialAnimationController.reverse();
          },
          backgroundColor: _colorTween.animate(radialAnimationController).value,
          child: Icon(
            Icons.circle,
            color: Colors.white,
          ),
        );
      },
      drawerBuilder: (context, animController) =>
          surroundingButtonsBuilder(context, animController, displayAngles),
    );
  }
}

// ******************************* //

void _removeTable(BuildContext context, int id) async {
  final supplier = Provider.of<Supplier>(context, listen: false);
  var delete = await popUpDelete(context);
  if (delete != null && delete) {
    supplier.removeTable(id);
  }
}
