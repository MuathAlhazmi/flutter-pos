import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:posapp/theme/rally.dart';
import 'package:provider/provider.dart';

import '../../../common/common.dart';
import '../../../provider/src.dart';
import '../../popup_del.dart';

class OrderCard extends StatefulWidget {
  final int index;

  const OrderCard(this.index);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistorySupplierByDate>(context);
    final order = provider.data.elementAt(widget.index);
    var del = order.isDeleted;
    return Stack(
      alignment: Alignment.center,
      children: [
        FractionallySizedBox(
          widthFactor: 0.95,
          child: Card(
            key: ObjectKey(order),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    del == true ? Colors.grey[400]!.withOpacity(0.5) : RallyColors.primaryColor,
                child: Text(order.id.toString()),
              ),
              title: Text(
                Common.extractYYYYMMDD3(order.checkoutTime),
                style: del == true ? TextStyle(color: Colors.grey[200]!.withOpacity(0.5)) : null,
              ),
              onLongPress: del == true
                  ? () async {
                      var result = await popUpDelete(
                        context,
                        title: Text(
                          AppLocalizations.of(context)?.retPopUpTitle ?? 'Ignore?',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                          ),
                        ),
                      );
                      if (result == true) {
                        order.isDeleted = false;

                        setState(() {});
                      }
                    }
                  : () async {
                      var result = await popUpDelete(
                        context,
                        title: Text(
                          AppLocalizations.of(context)?.history_delPopUpTitle ?? 'Ignore?',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                          ),
                        ),
                      );
                      if (result == true) {
                        await provider.ignoreOrder(order, widget.index);

                        setState(() {});
                      }
                    },
              onTap: () {
                Navigator.pushNamed(context, '/order-details', arguments: {
                  'state': TableModel.withOrder(
                    Order.create(
                      tableID: order.tableID,
                      lineItems: order.lineItems,
                      orderID: order.id,
                      checkoutTime: order.checkoutTime,
                      discountRate: order.discountRate,
                    ),
                  ),
                  'from': 'history',
                });
              },
              trailing: Text(
                Money.format(provider.saleAmountOf(order)),
                style: TextStyle(
                  letterSpacing: 3,
                  color:
                      del == true ? Colors.grey[200]!.withOpacity(0.5) : RallyColors.primaryColor,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
