// ignore_for_file: body_might_complete_normally_nullable

import 'package:brackets/brackets.dart';
import 'package:generator/shared/data.dart';
import 'package:generator/articles/article_meta.dart';
import 'package:generator/shared/page.dart';
import 'package:highlight/highlight.dart' hide Node;
import 'package:intl/intl.dart';
import 'package:pure/pure.dart';
import 'package:reify/reify.dart';
import 'package:web_reify/web_reify.dart';
import 'package:web_reify/src/html.dart';

String highlightCdn(
  String path,
) =>
    'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/$path.min';

MarkupNode highlightTheme(String name) => stylesheet(
      href: highlightCdn(
        'styles' / name,
      ),
    );

final _dateFormatter = DateFormat.yMMMMd();

const _codeTag = 'code';

int _estimateReadingTime(ContentNodes content) {
  const readingTime = 250;

  Iterable<String> dismantleText(Node node) sync* {
    if (node is Element && node.tag != _codeTag) {
      yield* (node.children ?? const []).expand(dismantleText);
    } else if (node is Text) {
      yield node.text;
    }
  }

  final words =
      content.expand(dismantleText).expand((text) => text.split(' ')).length;

  return (words / readingTime).round();
}

MarkupNode _meta(
  ArticleMeta meta,
  ContentNodes content,
) {
  final metaInfo = [
    _dateFormatter.format(meta.date),
    [(_estimateReadingTime(content)), 'minute', 'read'].join(' '),
    meta.tags.map((e) => e.replaceAll('#', '')).join(' · '),
  ];

  return metaInfo.map((e) => (e, null)).pipe(navigation);
}

typedef ParsedMarkdown = Iterable<Node>;

typedef AugmentedMdElement = (
  List<Node> children,
  Map<String, String>? attributes,
)?;

typedef ElementAugmentation = AugmentedMdElement Function(Element node);

AugmentedMdElement highlightCode(Element node) {
  final currentTag = node.tag;
  final class$ = node.attributes['class'];
  late final textContents = node.children?.first.textContent;

  if (currentTag == _codeTag && class$ != null) {
    return (
      [
        Text(
          class$
              .replaceAll('language-', '')
              .pipe(
                (language) => highlight.parse(
                  textContents!.replaceAll('&lt;', '<').replaceAll('&gt;', '>'),
                  language: language,
                ),
              )
              .toHtml(),
        ),
      ],
      {
        'class': '${class$} hljs',
        'data-highlighted': 'yes',
      }
    );
  }
}

AugmentedMdElement addHeaderLink(Element node) {
  final currentTag = node.tag;
  final generatedId = node.generatedId;
  late final textContents = node.children?.first.textContent;

  if (currentTag.startsWith('h') &&
      generatedId != null &&
      textContents != null) {
    return (
      [
        Text('$textContents '),
        Element('a', [
          Text('#'),
        ])
          ..attributes['href'] = '#$generatedId',
      ],
      null,
    );
  }
}

ParsedMarkdown preprocessMarkdownHtml(
  ContentNodes content,
  List<ElementAugmentation> augmentation,
) sync* {
  for (final node in content) {
    if (node is Element) {
      Element createElement(List<Node> children) => Element(node.tag, children)
        ..generatedId = node.generatedId
        ..footnoteLabel = node.footnoteLabel
        ..attributes.addAll(node.attributes);

      final current =
          augmentation.map((f) => f(node)).where((e) => e != null).firstOrNull;

      if (current != null) {
        final (children, attributes) = current;
        final element = createElement(children);
        if (attributes != null) element.attributes.addAll(attributes);

        yield element;
      } else {
        yield preprocessMarkdownHtml(node.children ?? const [], augmentation)
            .toList()
            .pipe(createElement);
      }
    } else {
      yield node;
    }
  }
}

Iterable<Node> addHeaderLinks(Iterable<Node> content) sync* {}

Item<Markup> article(Article article) {
  final (:meta, :data) = article;
  final content = data.content;
  final title = data.title;
  final keywords = meta.keywords;
  final description = meta.description;

  return (
    path: 'articles' / htmlFileSlug(title),
    data: page(
      meta: (
        description: description,
        title: data.title,
        keywords: keywords,
        urlSegments: ['articles', slugify(data.title)],
        type: OgType.article,
        og: {
          ('published_time', '${meta.date.toIso8601String()}Z'),
          ('author', yakovCodes / 'about'),
          ('section', 'Programming'),
          ...keywords.map((e) => ('tag', e))
        }
      ),
      body: [
        'h1'([
          'mark'([data.title.$]),
        ]),
        _meta(meta, content),
        'blockquote'([
          description.$,
        ]),
        hr,
        h(2, ['Contents'.$]),
        'blockquote'([
          documentContents((
            initialLevel: 2,
            nodes: content,
          )),
        ]),
        hr,
        preprocessMarkdownHtml(content, [highlightCode, addHeaderLink])
            .toList()
            .pipe(raw),
        highlightTheme('base16/dark-violet'),
      ],
    )
  );
}
