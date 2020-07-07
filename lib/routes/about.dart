import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

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
        children: <Widget>[
          Expanded(
            child: MediaQuery.of(context).orientation == Orientation.portrait
                ? Column(
                    children: <Widget>[
                      Expanded(
                        child: Image.asset('assets/images/logo.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          S.of(context).titleVersion,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .apply(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Image.asset('assets/images/logo.png'),
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
          ),
          Container(
            color: Theme.of(context).canvasColor,
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width,
                // Force canvas to take up 70% of available space.
                height: MediaQuery.of(context).size.height * 0.7,
              ),
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
