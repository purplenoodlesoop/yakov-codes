import 'package:brackets/brackets.dart';
import 'package:cord/cord.dart';
import 'package:generator/articles/article.dart';
import 'package:generator/shared/page.dart';
import 'package:generator/shared/data.dart';
import 'package:pure/pure.dart';
import 'package:reify/reify.dart';
import 'package:web_reify/web_reify.dart';
import 'package:web_reify/src/html.dart';

typedef HomeMeta = ({
  String description,
});

final $HomeMeta = (
  ('description', $String),
  //
).jsonSchema();

HomeMeta homeMeta(JsonMap map) => $HomeMeta.from(map).pipe((m) => (
      description: m.$1,
      //
    ));

typedef Home = Markdown<HomeMeta>;

Items<Markup> homeOutput(Iterable<Home> source) => source.map((source) {
      final (:meta, :data) = source;
      final title = data.title;

      return (
        path: htmlFileSlug(title),
        data: page(
          meta: (
            description: meta.description,
            keywords: defaultKeywords,
            type: OgType.website,
            og: {},
            title: title,
            urlSegments: [slugify(title)],
          ),
          body: [
            preprocessMarkdownHtml(data.content, [addHeaderLink])
                .toList()
                .pipe(raw),
          ],
        )
      );
    });
