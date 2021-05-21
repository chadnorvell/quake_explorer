import 'package:test/test.dart';

import 'package:tremblant_earth/data/usgs.dart';

void main() {
  group("data/usgs.dart", () {
    group("query", () {
      test("works", () async {
        var results =
            await query(startTime: DateTime.now().subtract(Duration(days: 1)));
        expect(results, isNot(equals(null)));
      });
    });
  });
}
