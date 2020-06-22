import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  /// The app version number.
  ///
  /// Keep this in sync with pubspec.yaml.
  final String _version = 'Weather · Right Here · Right Now · 1.0.0+1';

  /// The app information (in Markdown).
  ///
  /// Keep this in sync with README.md.
  final String _data = r'''
## Usage

Pull to refresh data.

Tap the bottom panel to reveal weather details.

## Credits

[Data.gov.sg](https://data.gov.sg/) datasets licensed under [Singapore Open Data License](https://data.gov.sg/open-data-licence). Access via API is subject to [API Terms of Service](https://data.gov.sg/privacy-and-website-terms#api-terms).

[Weather Icons](https://erikflowers.github.io/weather-icons/) licensed under [SIL OFL 1.1](http://scripts.sil.org/OFL).

[Unsplash](https://unsplash.com) photos licensed under [Unsplash License](https://unsplash.com/license) from contributors:
- [David Moum](https://unsplash.com/@davidmoum?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
- [Eric Muhr](https://unsplash.com/@ericmuhr?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
- [Fabio Neo Amato](https://unsplash.com/@cloudsdealer?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
- [Guillaume M.](https://unsplash.com/@guimgn?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
- [Jason Briscoe](https://unsplash.com/@jsnbrsc?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
- [Peyman Farmani](https://unsplash.com/@peymanfarmani?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

This app is written using [Flutter SDK](https://flutter.dev) 1.17.4 and includes the following third-party libraries:
- [flutter_markdown](https://pub.dev/packages/flutter_markdown) ^0.4.1
- [geolocator](https://pub.dev/packages/geolocator) ^5.3.1
- [http](https://pub.dev/packages/http) ^0.12.1
- [intl](https://pub.dev/packages/intl) ^0.16.1
- [url_launcher](https://pub.dev/packages/url_launcher) ^5.4.10
- [weather_icons](https://pub.dev/packages/weather_icons) ^2.0.1
''';

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
            child: Image.asset('assets/images/logo.png'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _version,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .apply(color: Colors.white),
            ),
          ),
          Container(
            color: Theme.of(context).canvasColor,
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(
                width: MediaQuery.of(context).size.width,
                // Force canvas to take up 60% of available space.
                height: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Markdown(
                data: _data,
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
