import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../theme/rally.dart';

const _targetTime = Duration(seconds: 1);

/// An extended version of [FloatingActionButton] that allows long press, fires a [onLongPress]
/// callback after 2s
///
/// Have a [CircularProgressIndicator] around showing progress
class AnimatedLongClickableFAB extends StatefulWidget {
  final VoidCallback onLongPress;

  const AnimatedLongClickableFAB({required this.onLongPress});

  @override
  _AnimatedLongClickableFABState createState() => _AnimatedLongClickableFABState();
}

class _AnimatedLongClickableFABState extends State<AnimatedLongClickableFAB>
    with TickerProviderStateMixin {
  Timer? t;
  late final AnimationController valueController, colorController;
  ColorTween cTween =
      ColorTween(begin: CupertinoColors.tertiarySystemFill, end: RallyColors.primaryColor);

  final tooltip = SuperTooltip(
    outsideBackgroundColor: Colors.transparent,
    borderColor: Colors.transparent,
    backgroundColor: RallyColors.primaryColor,
    shadowColor: RallyColors.primaryColor.withOpacity(.4),
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 25.0,
    borderWidth: 1.0,
    content: Builder(builder: (context) {
      return Material(
        type: MaterialType.transparency,
        child: Text(
          AppLocalizations.of(context)?.lobby_tooltip ?? '',
          style: TextStyle(
            fontFamily: 'Cairo',
          ),
          softWrap: true,
        ),
      );
    }),
  );

  _AnimatedLongClickableFABState() {
    valueController = AnimationController(
      duration: _targetTime,
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    colorController = AnimationController(duration: _targetTime, vsync: this);
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) => tooltip.show(context));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    valueController.dispose();
    colorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: AnimatedBuilder(
            animation: valueController,
            builder: (_, __) {
              return CircularProgressIndicator(
                strokeWidth: 4.0,
                value: valueController.value,
                valueColor: colorController.drive(cTween),
              );
            },
          ),
        ),
        // must be last to receive tap events
        FloatingActionButton(
          elevation: 0,

          onPressed: () {}, // ignore, let [GestureDetector] take care of this
          backgroundColor: RallyColors.primaryColor,
          child: GestureDetector(
            onTapDown: (_) {
              t = Timer(_targetTime, widget.onLongPress);
              valueController.forward();
              colorController.forward();
            },
            onTapUp: (_) {
              if (t != null && t!.isActive) t!.cancel();
              valueController.reset();
              colorController.reset();
            },
            onTapCancel: () {
              if (t != null && t!.isActive) t!.cancel();
              valueController.reset();
              colorController.reset();
            },
            child: Icon(
              CupertinoIcons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
