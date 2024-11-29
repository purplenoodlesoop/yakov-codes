import 'package:brackets/brackets.dart';
import 'package:generator/articles/article.dart';
import 'package:generator/articles/article_meta.dart';
import 'package:generator/articles/articles_rss.dart';
import 'package:generator/articles/index.dart';
import 'package:generator/shared/function.dart';
import 'package:pure/pure.dart';
import 'package:reify/reify.dart';

bool _isPublishable(Mode mode, DateTime now, Article article) {
  const lessOrEqual = [-1, 0];
  late final current = article.meta.date.compareTo(now);

  return mode.isLocal || lessOrEqual.contains(current);
}

Items<Markup> articlesOutput(Mode mode, Iterable<Article> articles) {
  final now = DateTime.now().pipe(
    (now) => DateTime(now.year, now.month, now.day),
  );
  final sorted = articles.where(_isPublishable.curry(mode)(now)).toList()
    ..sort(compareOn(
      (doc) => doc.meta.date,
      reversed: true,
    ));

  return [
    index(sorted),
    ...sorted.map(article),
    articlesRss(sorted),
  ];
}
