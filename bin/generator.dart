import 'package:generator/shared/data.dart';
import 'package:reify/reify.dart';
import 'package:pure/pure.dart';
import 'package:generator/articles/article_meta.dart';
import 'package:generator/articles/articles_output.dart';
import 'package:generator/home.dart';
import 'package:web_reify/web_reify.dart';

Rule<String> rules(Context ctx) => createSite((
      fullSite: fullSite,
      robots: {
        'User-agent': '*',
        'Disallow': '/cdn-cgi/',
      },
      sitemap: {
        'about': 1.0,
        'index': 0.9,
        'articles': 0.8,
        'privacy-policy': 0.7,
      },
      changefreq: 'hourly',
      pages: {
        markdown((
          input: 'markdown/home/*.md',
          parse: homeMeta,
          output: homeOutput,
        )),
        markdown((
          input: 'markdown/articles/*.md',
          parse: articleMeta,
          output: articlesOutput.apply(ctx.mode),
        )),
      },
    ));

Future<void> main(List<String> args) => generate(args, rules);
