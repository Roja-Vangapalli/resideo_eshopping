import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 100,
        constraints: BoxConstraints.expand(),
        child: FittedBox(
          fit: BoxFit.none,
          child: SizedBox(
            height: 100,
            width: 100,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: PlatformCircularProgressIndicator(
                  android: (_) => MaterialProgressIndicatorData(),
                  ios: (_) => CupertinoProgressIndicatorData(),
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ),
        decoration: BoxDecoration(
            color: Color.fromARGB(0, 105, 105, 105)),
      ),
    );
  }
}