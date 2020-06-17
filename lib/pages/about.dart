import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final String _title = 'Weather · Right Here · Right Now · 0.1';
  final String _data = r'''
## Usage

Pull to refresh data (capped at once every 15 minutes).

Tab the bottom panel to reveal more details.

## Credits

[Data.gov.sg](https://data.gov.sg/) datasets licensed under [Singapore Open Data License](https://data.gov.sg/open-data-licence). Access via API is subject to [API Terms of Service](https://data.gov.sg/privacy-and-website-terms#api-terms).

[Weather Icons](https://erikflowers.github.io/weather-icons/) licensed under [SIL OFL 1.1](http://scripts.sil.org/OFL).

This app is written using [Flutter SDK](https://flutter.dev) 1.17.3 and includes the following third-party libraries:
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
              _title,
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
