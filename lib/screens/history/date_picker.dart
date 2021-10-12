import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../provider/src.dart';

class DatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final provider = context.read<HistorySupplierByDate>();
        final range = provider.selectedRange;
        final dates = await showDialog(
            context: context,
            builder: (context) => SfDateRangePicker(
                initialSelectedRange: PickerDateRange(range.start, range.end),
                minDate: DateTime(2019),
                maxDate: DateTime.now()));
        if (dates != null && dates.isNotEmpty) {
          final newlySelectedRange = DateTimeRange(start: dates.first, end: dates.last);
          provider.selectedRange = newlySelectedRange;
        }
      },
      child: Icon(Icons.date_range),
    );
  }
}
