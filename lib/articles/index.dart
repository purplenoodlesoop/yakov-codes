import 'package:brackets/brackets.dart';
import 'package:generator/articles/article_meta.dart';
import 'package:generator/shared/page.dart';
import 'package:generator/shared/data.dart';
import 'package:generator/shared/function.dart';
import 'package:reify/reify.dart';
import 'package:web_reify/web_reify.dart';
import 'package:web_reify/src/html.dart';

Item<Markup> index(Iterable<Article> articleNames) => (
      path: 'index.html',
      data: page(
        meta: (
          description: 'List of articles published on $yakovCodes blog. '
              'The articles cover a wide range of topics from programming to '
              'personal development.',
          keywords: defaultKeywords,
          type: OgType.website,
          og: {},
          title: 'Articles - $yakovCodes',
          urlSegments: [],
        ),
        body: [
          h(2, ['Articles'.$]),
          'ul'([
            for (final name in articleNames)
              'li'([
                textLink(
                  text: name.data.title,
                  href: '/articles/${slugify(name.data.title)}',
                ),
                ' · ${formatDate(name.meta.date)}'.$,
              ])
          ])
        ],
      )
    );
