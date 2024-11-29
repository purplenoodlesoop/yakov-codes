import 'package:brackets/brackets.dart';
import 'package:generator/articles/article_meta.dart';
import 'package:generator/shared/data.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:reify/reify.dart';
import 'package:web_reify/web_reify.dart';

Item<Markup> articlesRss(List<Article> articles) => rss((
      author: (
        channelTitle: yakovCodes,
        email: contactMail,
        fullSite: fullSite,
        name: 'Yakov Karpov',
      ),
      items: articles.map((article) {
        final (:data, :meta) = article;

        return (
          content: md.renderToHtml(data.content).replaceAll('\n', '<br>'),
          title: data.title,
          date: meta.date,
          description: meta.description,
          link: 'articles' / slugify(data.title),
          tags: meta.tags,
        );
      }),
    ));
