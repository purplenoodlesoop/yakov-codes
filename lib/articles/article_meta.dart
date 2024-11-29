import 'package:cord/cord.dart';
import 'package:pure/pure.dart';
import 'package:web_reify/web_reify.dart';

final $ArticleFrontMatter = (
  // Tags for the article. Small list.
  ('tags', $List($String)).withDefault(const []),
  // Date the article will be published. Not published until this date,
  // should be checked periodically in GitHub Actions.
  ('publish', $DateTime),
  // Description of the article that is rendered in the meta tag, used for
  // SEO purposes
  ('description', $String).withDefault(''),
  // Keywords, also go into the meta tag for SEO purposes
  ('keywords', $List($String)).withDefault(const []),
).jsonSchema();

typedef ArticleMeta = ({
  List<String> tags,
  List<String> keywords,
  String description,
  DateTime date,
});

typedef Article = Markdown<ArticleMeta>;

ArticleMeta articleMeta(JsonMap map) =>
    map.pipe($ArticleFrontMatter.from).pipe((fm) => (
          tags: fm.$1,
          date: fm.$2,
          description: fm.$3,
          keywords: fm.$4,
        ));
