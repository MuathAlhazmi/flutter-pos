import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:posapp/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './table_icon.dart';
import '../../common/common.dart';
import '../../provider/src.dart';
import '../../theme/rally.dart';
import 'anim_longclick_fab.dart';

class LobbyScreen extends StatelessWidget {
  var languageCode = 'ar';

  @override
  Widget build(BuildContext context) {
    changeLocale() async {
      var prefs = await SharedPreferences.getInstance();
      languageCode = prefs.getString('languageCode') ?? 'ar';

      if (languageCode == 'en') {
        print(true);
        PosApp.setLocale(context, Locale('ar'));
      }
      if (languageCode == 'ar') {
        print(false);

        PosApp.setLocale(context, Locale('en'));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: BottomAppBar(
        color: RallyColors.primaryBackground,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Tooltip(
              message: AppLocalizations.of(context)!.lang_message,
              child: MaterialButton(
                onPressed: changeLocale,
                minWidth: MediaQuery.of(context).size.width / 3,
                shape: CustomShape(side: CustomShapeSide.left),
                child: Icon(Icons.language),
              ),
            ),
            Tooltip(
              message: AppLocalizations.of(context)!.lobby_report,
              child: MaterialButton(
                onPressed: () {
                  showBottomSheetMenu(context);
                },
                minWidth: MediaQuery.of(context).size.width / 3,
                shape: CustomShape(side: CustomShapeSide.left),
                child: Icon(CupertinoIcons.square_list),
              ),
            ),
            Tooltip(
              message: AppLocalizations.of(context)!.lobby_menuEdit,
              child: MaterialButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-menu'),
                minWidth: MediaQuery.of(context).size.width / 3,
                shape: CustomShape(side: CustomShapeSide.right),
                child: Icon(Icons.local_dining_sharp),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: AnimatedLongClickableFAB(
        onLongPress: () => _addTable(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      body: _InteractiveBody(),
    );
  }

  Future showBottomSheetMenu(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: RallyColors.primaryBackground,
      context: context,
      // isScrollControlled combined with shrinkWrap for minimal height in bottom sheet
      isScrollControlled: true,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)?.lobby_report.toUpperCase() ?? 'HISTORY',
                style: TextStyle(fontFamily: 'Cairo'),
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)?.lobby_journal.toUpperCase() ?? 'EXPENSE JOURNAL',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () => Navigator.pushNamed(context, '/expense'),
            ),
          ],
        );
      },
    );
  }
}

/// Allow panning & dragging widgets inside...
class _InteractiveBody extends StatelessWidget {
  /// The key to container (1), must be passed into all DraggableWidget widgets in Stack
  final GlobalKey bgKey = GlobalKey();

  final TransformationController transformController = TransformationController();

  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<Supplier>(context, listen: true);
    return InteractiveViewer(
      maxScale: 2.0,
      transformationController: transformController,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: RallyColors.primaryBackground),
          ),
          // create a container (1) here to act as fixed background for the entire screen,
          // pan & scale effect from InteractiveViewer will actually interact with this container
          // thus also easily scale & pan all widgets inside the stack
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  key: bgKey,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          for (var model in supplier.tables)
            DraggableWidget(
              x: model.getOffset().x,
              y: model.getOffset().y,
              containerKey: bgKey,
              transformController: transformController,
              onDragEnd: (x, y) {
                model.setOffset(Coordinate(x, y), supplier);
              },
              key: ObjectKey(model),
              child: TableIcon(table: model),
            ),
        ],
      ),
    );
  }
}

// ******************************* //

void _addTable(BuildContext context) {
  var supplier = Provider.of<Supplier>(context, listen: false);
  supplier.addTable();
}
