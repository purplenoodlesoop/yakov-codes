import 'package:brackets/brackets.dart';
import 'package:generator/shared/data.dart';
import 'package:pure/pure.dart';
import 'package:web_reify/web_reify.dart';
import 'package:web_reify/src/html.dart';

typedef LinkDescription = (String label, String? ref);

LinkDescription mailLink(String title) => (
      title,
      'mailto:$contactMail',
    );

extension Intersperse<T> on Iterable<T> {
  Iterable<T> intersperse(T separator) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator;
        yield iterator.current;
      }
    }
  }
}

MarkupNode navigation(Iterable<LinkDescription> elements) => 'nav'(
      elements
          .map<MarkupNode>(
            (e) =>
                e.$2?.pipe((ref) => textLink(text: e.$1, href: ref)) ?? e.$1.$,
          )
          .intersperse(' | '.$),
    );

final hr = 'hr'(null);

Markup page({
  required PageMeta meta,
  required Markup body,
}) =>
    basePage(
      (
        info: (
          fullSite: fullSite,
          imageUrl: Uri.https(
            'dynamic-og-image-generator.vercel.app',
            '/api/generate',
            {
              'title': meta.title,
              'author': 'Yakov K.',
              'websiteUrl': 'https://$yakovCodes',
              'avatar': 'https://avatars.githubusercontent.com/u/68401994',
              'theme': 'shadesOfPurple',
            },
          ).toString(),
          accentColor: '#62389a',
        ),
        meta: meta,
        head: [
          stylesheet(href: 'https://fonts.xz.style/serve/inter'),
          stylesheet(
            href:
                'https://cdn.jsdelivr.net/npm/@exampledev/new.css@1.1.2/new.min',
          ),
          stylesheet(href: 'https://newcss.net/theme/night'),
          stylesheet(href: '/css/styles'),
        ],
      ),
      children: [
        'header'([
          'h1'([
            'mark'([yakovCodes.$]),
          ]),
          navigation([
            ('Articles', '/'),
            ('About', '/about'),
            mailLink('Contact'),
          ]),
        ]),
        'main'(body),
        'footer'([
          hr,
          'p'(['© 2024 Yakov Karpov'.$]),
          'p'(['Made with 💜 in Dart'.$]),
          navigation([
            ('Github', 'https://github.com/purplenoodlesoop'),
            ('Twitter', 'https://twitter.com/purplesoops'),
            ('RSS', '/rss.xml'),
            mailLink('Email'),
            ('Privacy', '/privacy-policy'),
          ]),
        ]),
      ],
    );
