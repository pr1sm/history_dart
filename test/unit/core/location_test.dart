@TestOn('browser || vm')

import 'package:test/test.dart';

import 'package:history/src/core/location.dart';

void main() {
  group('Location', () {
    void compareToExpected(Location loc,
        [String pathname = '/',
        String hash = '',
        String search = '',
        String key = null,
        String state = null,
        String path = '/']) {
      expect(loc.pathname, equals(pathname));
      expect(loc.hash, equals(hash));
      expect(loc.search, equals(search));
      expect(loc.key, key == null ? isNull : equals(key));
      expect(loc.state, state == null ? isNull : equals(state));
      expect(loc.path, equals(path));
      expect(
          loc.toString(),
          equals(
              'Pathname: "${pathname}", Hash: "${hash}", Search: "${search}", Key: "${key}", State: "${state.toString()}"'));
    }

    group('default constructor', () {
      test('constructs with no parameters', () {
        Location loc = new Location();
        compareToExpected(loc);
      });

      test('constructs with pathname', () {
        Location loc = new Location(pathname: 'pathname');
        compareToExpected(loc, 'pathname', '', '', null, null, 'pathname');
      });

      test('constructs when path is passed to pathname', () {
        Location loc = new Location(pathname: '/pathname?search#hash');
        compareToExpected(loc, '/pathname', 'hash', 'search', null, null,
            '/pathname?search#hash');
      });

      test('overrides hash and search when path is passed to pathname', () {
        Location loc = new Location(
            pathname: '/pathname?search#hash',
            hash: 'myHash',
            search: 'mySearch');
        compareToExpected(loc, '/pathname', 'hash', 'search', null, null,
            '/pathname?search#hash');
      });

      test('constructs with hash', () {
        Location loc = new Location(hash: 'hash');
        compareToExpected(loc, '/', 'hash', '', null, null, '/#hash');
      });

      test('constructs with search', () {
        Location loc = new Location(search: 'search');
        compareToExpected(loc, '/', '', 'search', null, null, '/?search');
      });

      test('constructs with key', () {
        Location loc = new Location(key: 'key');
        compareToExpected(loc, '/', '', '', 'key', null, '/');
      });

      test('constructs with state', () {
        Location loc = new Location(state: 'state');
        compareToExpected(loc, '/', '', '', null, 'state', '/');
      });

      test('constructs when null is given', () {
        Location loc = new Location(
            pathname: null, hash: null, key: null, search: null, state: null);
        compareToExpected(loc);
      });

      test('throws FormatException on invalid path', () {
        try {
          new Location(pathname: '%_:?invalid#path');
        } on FormatException catch (_) {
          return;
        }
        fail('FormatException should be thrown for invalid path');
      });
    });

    group('copy constructor', () {
      Location base;

      setUp(() {
        base = new Location(
            pathname: 'basepath',
            hash: 'basehash',
            search: 'basesearch',
            key: 'basekey',
            state: 'basestate');
      });

      test('copies when no overrides are given', () {
        Location loc = new Location.copy(base);
        expect(loc, equals(base));
        expect(loc.hashCode, equals(base.hashCode));
        compareToExpected(loc, 'basepath', 'basehash', 'basesearch', 'basekey',
            'basestate', 'basepath?basesearch#basehash');
      });

      test('copies when null overrides are given', () {
        Location loc = new Location.copy(base,
            pathname: null, hash: null, search: null, key: null, state: null);
        expect(loc, equals(base));
        compareToExpected(loc, 'basepath', 'basehash', 'basesearch', 'basekey',
            'basestate', 'basepath?basesearch#basehash');
      });

      test('overrides pathname', () {
        Location loc = new Location.copy(base, pathname: 'newpath');
        expect(loc, isNot(equals(base)));
        expect(loc.hashCode, isNot(equals(base.hashCode)));
        compareToExpected(loc, 'newpath', 'basehash', 'basesearch', 'basekey',
            'basestate', 'newpath?basesearch#basehash');
      });

      test('overrides when path is passed to pathname', () {
        Location loc =
            new Location.copy(base, pathname: '/pathname?search#hash');
        compareToExpected(loc, '/pathname', 'hash', 'search', 'basekey',
            'basestate', '/pathname?search#hash');
      });

      test('overrides hash', () {
        Location loc = new Location.copy(base, hash: 'newhash');
        expect(loc, isNot(equals(base)));
        expect(loc.hashCode, isNot(equals(base.hashCode)));
        compareToExpected(loc, 'basepath', 'newhash', 'basesearch', 'basekey',
            'basestate', 'basepath?basesearch#newhash');
      });

      test('overrides search', () {
        Location loc = new Location.copy(base, search: 'newsearch');
        expect(loc, isNot(equals(base)));
        expect(loc.hashCode, isNot(equals(base.hashCode)));
        compareToExpected(loc, 'basepath', 'basehash', 'newsearch', 'basekey',
            'basestate', 'basepath?newsearch#basehash');
      });

      test('overrides key', () {
        Location loc = new Location.copy(base, key: 'newkey');
        expect(loc, isNot(equals(base)));
        expect(loc.hashCode, isNot(equals(base.hashCode)));
        compareToExpected(loc, 'basepath', 'basehash', 'basesearch', 'newkey',
            'basestate', 'basepath?basesearch#basehash');
      });

      test('overrides state', () {
        Location loc = new Location.copy(base, state: 'newstate');
        expect(loc, isNot(equals(base)));
        expect(loc.hashCode, isNot(equals(base.hashCode)));
        compareToExpected(loc, 'basepath', 'basehash', 'basesearch', 'basekey',
            'newstate', 'basepath?basesearch#basehash');
      });
    });

    group('fromMap constructor', () {
      test('constructs with pathname', () {
        var map = {
          'pathname': 'pathname',
        };
        Location loc = new Location.fromMap(map);
        compareToExpected(loc, 'pathname', '', '', null, null, 'pathname');
      });

      test('constructs when path is passed to pathname', () {
        var map = {
          'pathname': 'pathname?search#hash',
        };
        Location loc = new Location.fromMap(map);
        compareToExpected(loc, 'pathname', 'hash', 'search', null, null,
            'pathname?search#hash');
      });

      test('overrides hash and search when path is passed to pathname', () {
        var map = {
          'pathname': 'pathname?search#hash',
          'hash': 'myHash',
          'search': 'mySearch',
        };
        Location loc = new Location.fromMap(map);
        compareToExpected(loc, 'pathname', 'hash', 'search', null, null,
            'pathname?search#hash');
      });

      test('constructs with hash', () {
        var map = {
          'hash': 'hash',
        };
        Location loc = new Location.fromMap(map);
        compareToExpected(loc, '/', 'hash', '', null, null, '/#hash');
      });

      test('constructs with search', () {
        var map = {
          'search': 'search',
        };
        Location loc = new Location.fromMap(map);
        compareToExpected(loc, '/', '', 'search', null, null, '/?search');
      });

      test('constructs with key', () {
        var map = {
          'key': 'key',
        };
        Location loc = new Location.fromMap(map);
        compareToExpected(loc, '/', '', '', 'key', null, '/');
      });

      test('constructs with state', () {
        var map = {
          'state': 'state',
        };
        Location loc = new Location.fromMap(map);
        compareToExpected(loc, '/', '', '', null, 'state', '/');
      });

      test('constructs when null is given', () {
        Location loc = new Location.fromMap(null);
        compareToExpected(loc);
      });
    });

    group('relativeTo constructor', () {
      Location base;

      setUp(() {
        base = new Location(
            pathname: '/base/path',
            hash: 'basehash',
            search: 'basesearch',
            key: 'basekey',
            state: 'basestate');
      });

      test('constructs default values with null base', () {
        Location loc = new Location.relativeTo(null);
        compareToExpected(loc);
      });

      test('constructs with no relation with null base', () {
        Location loc = new Location.relativeTo(null, pathname: 'myPath');
        compareToExpected(loc, 'myPath', '', '', null, null, 'myPath');
      });

      test('constructs with no absolute relation with null base', () {
        Location loc = new Location.relativeTo(null, pathname: '/myPath');
        compareToExpected(loc, '/myPath', '', '', null, null, '/myPath');
      });

      test('constructs with no relation when absolute path is used', () {
        Location loc = new Location.relativeTo(base, pathname: '/myPath');
        compareToExpected(loc, '/myPath', '', '', null, null, '/myPath');
      });

      test('constructs path with current parent when fragment is used', () {
        Location loc = new Location.relativeTo(base, pathname: 'path2');
        compareToExpected(
            loc, '/base/path2', '', '', null, null, '/base/path2');
      });

      test('constructs path relative to base when "./" is used', () {
        Location loc = new Location.relativeTo(base, pathname: './path2');
        compareToExpected(
            loc, '/base/path2', '', '', null, null, '/base/path2');
      });

      test('constructs path relative to base when "../" is used', () {
        Location loc = new Location.relativeTo(base, pathname: '../path2');
        compareToExpected(loc, '/path2', '', '', null, null, '/path2');
      });

      test('constructs path relative to base when "../../" is used', () {
        base = new Location(
            pathname: '/base/path/levels',
            hash: 'basehash',
            search: 'basesearch',
            key: 'basekey',
            state: 'basestate');
        Location loc =
            new Location.relativeTo(base, pathname: '../../path2/path3');
        compareToExpected(
            loc, '/path2/path3', '', '', null, null, '/path2/path3');
      });

      test(
          'constructs path relative to base when going past the root with "../"s is used',
          () {
        base = new Location(
            pathname: '/base/path/levels',
            hash: 'basehash',
            search: 'basesearch',
            key: 'basekey',
            state: 'basestate');
        Location loc =
            new Location.relativeTo(base, pathname: '../../../../../../path2');
        compareToExpected(loc, '/path2', '', '', null, null, '/path2');
      });

      test('constructs with given parameters instead of base', () {
        Location loc = new Location.relativeTo(base,
            pathname: 'path2',
            hash: 'myHash',
            search: 'mySearch',
            state: 'state',
            key: 'key');
        compareToExpected(loc, '/base/path2', 'myHash', 'mySearch', 'key',
            'state', '/base/path2?mySearch#myHash');
      });

      test('overrides hash and search when path is given for pathname', () {
        Location loc = new Location.relativeTo(base,
            pathname: 'path2?search#hash', hash: 'myHash', search: 'mySearch');
        compareToExpected(loc, '/base/path2', 'hash', 'search', null, null,
            '/base/path2?search#hash');
      });
    });

    group('relateTo', () {
      Location base;

      setUp(() {
        base = new Location(
            pathname: '/base/path',
            hash: 'basehash',
            search: 'basesearch',
            key: 'basekey',
            state: 'basestate');
      });

      test('works with default values with null base', () {
        Location loc = new Location();
        loc.relateTo(null);
        compareToExpected(loc);
      });

      test('works with no relation with null base', () {
        Location loc = new Location(pathname: 'myPath');
        loc.relateTo(null);
        compareToExpected(loc, 'myPath', '', '', null, null, 'myPath');
      });

      test('works with no absolute relation with null base', () {
        Location loc = new Location(pathname: '/myPath');
        loc.relateTo(null);
        compareToExpected(loc, '/myPath', '', '', null, null, '/myPath');
      });

      test('works with no relation when absolute path is used', () {
        Location loc = new Location(pathname: '/myPath');
        loc.relateTo(base);
        compareToExpected(loc, '/myPath', '', '', null, null, '/myPath');
      });

      test('works when path with current parent when fragment is used', () {
        Location loc = new Location(pathname: 'path2');
        loc.relateTo(base);
        compareToExpected(
            loc, '/base/path2', '', '', null, null, '/base/path2');
      });

      test('works when path relative to base when "./" is used', () {
        Location loc = new Location(pathname: './path2');
        loc.relateTo(base);
        compareToExpected(
            loc, '/base/path2', '', '', null, null, '/base/path2');
      });

      test('works when path relative to base when "../" is used', () {
        Location loc = new Location(pathname: '../path2');
        loc.relateTo(base);
        compareToExpected(loc, '/path2', '', '', null, null, '/path2');
      });

      test('works when path relative to base when "../../" is used', () {
        base = new Location(
            pathname: '/base/path/levels',
            hash: 'basehash',
            search: 'basesearch',
            key: 'basekey',
            state: 'basestate');
        Location loc = new Location(pathname: '../../path2/path3');
        loc.relateTo(base);
        compareToExpected(
            loc, '/path2/path3', '', '', null, null, '/path2/path3');
      });

      test(
          'works when path relative to base when going past the root with "../"s is used',
          () {
        base = new Location(
            pathname: '/base/path/levels',
            hash: 'basehash',
            search: 'basesearch',
            key: 'basekey',
            state: 'basestate');
        Location loc = new Location(pathname: '../../../../../../path2');
        loc.relateTo(base);
        compareToExpected(loc, '/path2', '', '', null, null, '/path2');
      });

      test('works with given parameters instead of base', () {
        Location loc = new Location(
            pathname: 'path2',
            hash: 'myHash',
            search: 'mySearch',
            state: 'state',
            key: 'key');
        loc.relateTo(base);
        compareToExpected(loc, '/base/path2', 'myHash', 'mySearch', 'key',
            'state', '/base/path2?mySearch#myHash');
      });

      test('uses base pathname when current pathname is empty', () {
        Location loc = new Location(pathname: '?search#hash');
        loc.relateTo(base);
        compareToExpected(loc, '/base/path', 'hash', 'search', null, null,
            '/base/path?search#hash');
      });
    });
  });
}
