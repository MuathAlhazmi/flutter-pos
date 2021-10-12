import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../provider/src.dart';
import '../../../theme/rally.dart';

class HistoryOrderLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupedData = context.select<HistorySupplierByLine, List<List<dynamic>>>(
      (provider) => provider.groupedData,
    );

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(48, 60, 48, 48),
      child: _drawLineChart(context, groupedData),
    );
  }

  /// for bigger number `getEfficientInterval` still display too much
  /// this is a adjustment to that issue
  double _interval(List<List<dynamic>> groupedData) {
    final maxVal = groupedData.fold<double>(0.0, (prev, e) {
      if (prev < e[1]) {
        return e[1];
      }
      return prev;
    });
    final minVal = groupedData.fold<double>(double.maxFinite, (prev, e) {
      if (prev >= e[1] && e[1] > 0) {
        return e[1];
      }
      return prev;
    });
    const maxSteps = 19;
    final expectedInterval = (maxVal % minVal) != 0 ? (maxVal % minVal) : minVal;
    final expectedSteps = maxVal ~/ expectedInterval;
    final modifier = (expectedSteps ~/ maxSteps) + 1;
    return expectedInterval * modifier;
  }

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  Widget _drawLineChart(BuildContext context, List<List<dynamic>> groupedData) {
    var showTooltipsOnAllSpots = false;
    final _spots = _mapGroupDataToSpots(groupedData);
    final _mainChart = LineChartBarData(
      spots: _spots,
      colors: gradientColors,
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      isCurved: true,
      preventCurveOverShooting: true,
      belowBarData: BarAreaData(
        show: true,
        colors: gradientColors.map((color) => color.withOpacity(0.45)).toList(),
      ),
    );
    return _spots.isEmpty
        ? Center(child: Text('No data'))
        : StatefulBuilder(
            builder: (context, setState) => LineChart(
              LineChartData(
                backgroundColor: RallyColors.primaryBackground,
                lineTouchData: LineTouchData(
                  // show tooltips on all spots on long tap
                  touchCallback: (LineTouchResponse touchResponse) {
                    Timer? _timer;
                    if (touchResponse.touchInput.down) {
                      _timer = Timer(Duration(seconds: 1), () {
                        setState(() {
                          showTooltipsOnAllSpots = touchResponse.touchInput.down;
                        });
                      });
                    } else {
                      _timer?.cancel();
                      setState(() {
                        showTooltipsOnAllSpots = touchResponse.touchInput.down;
                      });
                    }
                  },
                  // must disable this for showingTooltipIndicators to work
                  handleBuiltInTouches: !showTooltipsOnAllSpots,
                  touchSpotThreshold: 20.0,
                ),
                borderData: FlBorderData(
                    show: true, border: Border.all(color: const Color(0xff37434d), width: 2)),
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (value) => TextStyle(
                      color: Color(0xff67727d),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    margin: 20.0,
                    interval: _interval(groupedData),
                  ),
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (value) => TextStyle(
                      color: Color(0xff67727d),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    margin: 20, // convert index value back to yyyymmdd
                    getTitles: (idx) => groupedData[idx.toInt()][0],
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xff37434d),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xff37434d),
                      strokeWidth: 1,
                    );
                  },
                ),
                minY: 0.0,
                showingTooltipIndicators: showTooltipsOnAllSpots
                    ? [
                        ..._spots.map(
                          (spot) => ShowingTooltipIndicators([LineBarSpot(_mainChart, 0, spot)]),
                        ),
                      ]
                    : [],
                lineBarsData: [_mainChart],
              ),
            ),
          );
  }

  List<FlSpot> _mapGroupDataToSpots(List<List<dynamic>> groupedData) {
    return groupedData.asMap().entries.map((entry) {
      // second element of the inner list is set as the value
      return FlSpot(double.parse(entry.key.toDouble().toStringAsFixed(1)),
          double.parse(entry.value[1].toDouble().toStringAsFixed(1)));
    }).toList();
  }
}
