import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:posapp/theme/rally.dart';
import '../avatar.dart';

const double height = 85.0;

@immutable
class Counter extends StatefulWidget {
  final _memoizer = AsyncMemoizer();
  final int startingValue;

  final ImageProvider? imgProvider;

  final String title;
  final String subtitle;
  final TextEditingController textEditingController;
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  Counter(
    this.startingValue, {
    required this.onIncrement,
    required this.onDecrement,
    this.imgProvider,
    required this.title,
    required this.subtitle,
    Key? key,
  })  : textEditingController = TextEditingController(
          text: startingValue.toString(),
        ),
        super(key: key);

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> with SingleTickerProviderStateMixin {
  late AnimationController animController;

  _CounterState() {
    animController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  int add(AnimationController animController, int value) {
    if (value == 0) animController.forward();

    value++;
    widget.textEditingController.text = (value).toString();
    widget.onIncrement.call(value);
    return value;
  }

  int sub(AnimationController animationController, int value) {
    // animate to "start" color when back to 0
    if (value == 1) animController.reverse();

    if (value <= 0) return 0;

    value--;
    widget.textEditingController.text = (value).toString();
    widget.onDecrement.call(value);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    var value = int.parse(widget.textEditingController.text);

    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        if (widget.startingValue != 0) {
          widget._memoizer.runOnce(() {
            animController.forward();
          });
        }

        final colorTween = ColorTween(
          begin: Theme.of(context).cardTheme.color, // disabled color
          end: RallyColors.primaryColor.withOpacity(.5), // hightlight if > 0
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 85,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: colorTween.animate(animController).value,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => value = add(animController, value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          minVerticalPadding: 2.0,
                          horizontalTitleGap: 2.0,
                          contentPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          title: Text(
                            widget.title,
                            style: TextStyle(fontFamily: 'Cairo'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            widget.subtitle,
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FloatingActionButton(
                          backgroundColor: Colors.redAccent,
                          // decrease
                          heroTag: null,
                          onPressed: () => value = sub(animController, value),
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: widget.textEditingController,
                          enabled: false,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Expanded(
                        child: FloatingActionButton(
                          backgroundColor: RallyColors.primaryColor,
                          // increase
                          heroTag: null,
                          onPressed: () => value = add(animController, value),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        height: height,
                        width: height,
                        margin: const EdgeInsets.only(left: 2.0),
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          shadows: [
                            BoxShadow(
                              color: RallyColors.primaryColor.withOpacity(.5),
                              blurRadius: animController.value * 6,
                              spreadRadius: animController.value * 9,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                      const SizedBox(width: 2.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Avatar(imgProvider: widget.imgProvider),
    );
  }
}
