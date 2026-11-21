import 'package:flutter_test/flutter_test.dart';
import 'package:md_portfolio/core/utils/drive_url_helper.dart';

void main() {
  group('optimizeCloudinaryUrl', () {
    test('adds format, quality and size to a plain upload URL', () {
      expect(
        optimizeCloudinaryUrl('https://res.cloudinary.com/yoqbyyb9/image/upload/'
            'v1732000000/portfolio/flowery.png'),
        'https://res.cloudinary.com/yoqbyyb9/image/upload/'
        'f_auto,q_auto,w_1600,c_limit/v1732000000/portfolio/flowery.png',
      );
    });

    test('leaves URLs that already have a transformation alone', () {
      const url = 'https://res.cloudinary.com/yoqbyyb9/image/upload/'
          'w_400,c_fill/v1/portfolio/me.jpg';
      expect(optimizeCloudinaryUrl(url), url);
    });

    test('leaves non-Cloudinary URLs alone', () {
      const url = 'https://example.com/image/upload/x.png';
      expect(optimizeCloudinaryUrl(url), url);
    });
  });

  test('Drive links still get their fallback candidates', () {
    final c = buildDriveImageCandidates(
        'https://drive.google.com/file/d/abc123/view?usp=sharing');
    expect(c.first, contains('thumbnail?id=abc123'));
    expect(c.length, greaterThan(1));
  });
}
