import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_icons/weather_icons.dart';

import '../generated/l10n.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.portrait
              ? Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: FittedBox(
                            child: BoxedIcon(WeatherIcons.night_alt_cloudy),
                          ),
                        ),
                        Text(
                          S.of(context).titleVersion,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .apply(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      FittedBox(
                        child: BoxedIcon(WeatherIcons.night_alt_cloudy),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        S.of(context).titleVersion,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .apply(color: Colors.white),
                      ),
                    ],
                  ),
                ),
          Expanded(
            flex: 4, // 80%, in portrait-mode only.
            child: Container(
              color: Theme.of(context).canvasColor,
              child: Markdown(
                data: S.of(context).aboutMarkdown,
                onTapLink: (url) async {
                  if (await canLaunch(url)) launch(url);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
