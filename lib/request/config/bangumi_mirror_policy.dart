import 'package:kazumi/utils/bangumi_mirror_credentials.dart';

class BangumiMirrorPolicy {
  BangumiMirrorPolicy._();

  static const _mirrorableHosts = {
    'api.bgm.tv',
    'next.bgm.tv',
  };

  static bool get hasCredentials {
    final id = bangumiMirrorCredentials['id'] ?? '';
    final key = bangumiMirrorCredentials['value'] ?? '';
    return id.isNotEmpty && key.isNotEmpty;
  }

  static bool isProtectedRequest(String method, Uri uri) {
    if (method.toUpperCase() == 'POST') {
      return uri.path == '/v0/search/subjects';
    }
    if (method.toUpperCase() != 'GET') {
      return false;
    }

    return uri.path.startsWith('/p1/subjects/') &&
            uri.path.endsWith('/comments') ||
        uri.path.startsWith('/p1/episodes/') &&
            uri.path.endsWith('/comments') ||
        uri.path.startsWith('/p1/characters/') &&
            uri.path.endsWith('/comments');
  }

  static bool shouldMirror({
    required String method,
    required Uri uri,
    required bool enabled,
  }) {
    if (!enabled || !_mirrorableHosts.contains(uri.host)) {
      return false;
    }

    // Fork builds have no mirror credentials, so protected requests must
    // fall back to the official API instead of receiving an unsigned 401.
    if (isProtectedRequest(method, uri) && !hasCredentials) {
      return false;
    }

    return true;
  }
}
