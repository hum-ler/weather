import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final String _title = 'Weather · Right Here · Right Now · 0.1';
  final String _data = r'''
## Credits

[Data.gov.sg](https://data.gov.sg/) datasets licensed under [Singapore Open Data License](https://data.gov.sg/open-data-licence). Access via API is subject to [API Terms of Service](https://data.gov.sg/privacy-and-website-terms#api-terms).

[Weather Icons](https://erikflowers.github.io/weather-icons/) licensed under [SIL OFL 1.1](http://scripts.sil.org/OFL).
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
            // TODO: To cater for landscape orientation, it might be better to
            // crop the image and allow it to scale automatically.
            child: Image.asset(
              'assets/images/logo.png',
              width: 120.0,
              height: 120.0,
              fit: BoxFit.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
