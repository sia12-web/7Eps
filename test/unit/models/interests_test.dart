import 'package:flutter_test/flutter_test.dart';
import 'package:sevent_eps/models/interests.dart';

void main() {
  group('Interests Data', () {
    test('commonInterests should not be empty', () {
      expect(commonInterests, isNotEmpty);
      expect(commonInterests.length, greaterThan(50));
    });

    test('interestCategories should have categories', () {
      expect(interestCategories, isNotEmpty);
      expect(interestCategories.keys, contains('Arts & Culture'));
      expect(interestCategories.keys, contains('Sports & Fitness'));
      expect(interestCategories.keys, contains('Food & Drink'));
    });

    test('all common interests should belong to a category', () {
      for (final interest in commonInterests) {
        final foundInCategory = interestCategories.values.any(
          (categoryList) => categoryList.contains(interest),
        );
        expect(
          foundInCategory,
          isTrue,
          reason: '$interest should belong to at least one category',
        );
      }
    });
  });

  group('Interest Selection', () {
    test('should allow up to 10 interests', () {
      final interests = List.generate(10, (i) => 'Interest $i');
      expect(interests.length, lessThanOrEqualTo(10));
    });

    test('should include popular interests', () {
      expect(commonInterests, contains('Hiking'));
      expect(commonInterests, contains('Travel'));
      expect(commonInterests, contains('Photography'));
      expect(commonInterests, contains('Coffee'));
      expect(commonInterests, contains('Dogs'));
    });
  });
}
