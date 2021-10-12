import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:posapp/theme/rally.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import 'first_tab/order_list.dart';
import 'second_tab/order_linechart.dart';

// heavy usage of Listenable objects to gain finer controls over widget rebuilding scope.

@immutable
class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RallyColors.cardBackground,
        toolbarHeight: 100,
        title: _LeadingTitle(),
        bottomOpacity: 0.5,
        bottom: TabBar(
          indicatorColor: RallyColors.primaryColor,
          tabs: [
            Tab(icon: Icon(CupertinoIcons.line_horizontal_3_decrease_circle)),
            Tab(icon: Icon(CupertinoIcons.chart_bar_circle)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  inactiveTrackColor: RallyColors.primaryColor.withOpacity(.2),
                  inactiveThumbColor: RallyColors.primaryColor.withOpacity(.4),
                  activeColor: RallyColors.primaryColor,
                  value: context.select((HistorySupplierByDate s) => s.discountFlag),
                  onChanged: (s) => context.read<HistorySupplierByDate>().discountFlag = s,
                ),
                Text(
                  AppLocalizations.of(context)?.history_toggleDiscount ?? 'Apply Discount Rate',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.apply(fontSizeFactor: 0.7, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),

          // fix the text size of the "current date"
          // Theme(
          //   data: Theme.of(context).copyWith(
          //     accentColor: RallyColors.primaryColor,
          //     primaryColor: RallyColors.primaryColor,
          //     textTheme: TextTheme(
          //       button: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       overline: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       caption: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       subtitle1: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       subtitle2: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       headline6: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       headline1: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       headline5: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       headline2: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       headline3: TextStyle(fontSize: 13, fontFamily: 'Cairo'),
          //       bodyText2: TextStyle(fontSize: 15, fontFamily: 'Cairo'),
          //       headline4: TextStyle(fontSize: 11, fontFamily: 'Cairo'),
          //       bodyText1: TextStyle(fontSize: 15, fontFamily: 'Cairo'),
          //     ),
          //   ),
          //   child: DatePicker(),
          // ),
        ],
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HistoryOrderList(),
          HistoryOrderLineChart(),
        ],
      ),
    );
  }
}

class _LeadingTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistorySupplierByDate>(context);
    final price = provider.sumAmount;
    final range = provider.selectedRange;
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.vertical,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            '${Money.format(price)}',
            style: TextStyle(
              color: RallyColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        Text(
          '(${Common.extractYYYYMMDD2(range.start)} - ${Common.extractYYYYMMDD2(range.end)})',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}
