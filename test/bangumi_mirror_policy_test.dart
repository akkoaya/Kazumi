import 'package:kazumi/request/config/bangumi_mirror_policy.dart';
import 'package:flutter_test/flutter_test.dart';

Uri _bangumiUrl(String path) => Uri.parse('https://api.bgm.tv$path');

void main() {
  group('BangumiMirrorPolicy', () {
    test('unprotected requests can use the mirror', () {
      final shouldMirror = BangumiMirrorPolicy.shouldMirror(
        method: 'GET',
        uri: _bangumiUrl('/v0/subjects/6016'),
        enabled: true,
      );

      expect(shouldMirror, isTrue);
    });

    test('protected search falls back without credentials', () {
      expect(BangumiMirrorPolicy.hasCredentials, isFalse);

      final shouldMirror = BangumiMirrorPolicy.shouldMirror(
        method: 'POST',
        uri: _bangumiUrl('/v0/search/subjects'),
        enabled: true,
      );

      expect(shouldMirror, isFalse);
    });

    test('protected comments fall back without credentials', () {
      for (final path in [
        '/p1/subjects/6016/comments',
        '/p1/episodes/1/comments',
        '/p1/characters/1/comments',
      ]) {
        final shouldMirror = BangumiMirrorPolicy.shouldMirror(
          method: 'GET',
          uri: _bangumiUrl(path),
          enabled: true,
        );

        expect(shouldMirror, isFalse, reason: path);
      }
    });

    test('disabled or unrelated hosts never use the mirror', () {
      expect(
        BangumiMirrorPolicy.shouldMirror(
          method: 'GET',
          uri: _bangumiUrl('/v0/subjects/6016'),
          enabled: false,
        ),
        isFalse,
      );
      expect(
        BangumiMirrorPolicy.shouldMirror(
          method: 'GET',
          uri: Uri.parse('https://example.com/v0/subjects/6016'),
          enabled: true,
        ),
        isFalse,
      );
    });
  });
}
