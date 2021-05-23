import "package:test/test.dart";

import "package:quake_explorer/model/event.dart";

void main() {
  group("model/event.dart", () {
    group("EventQuery", () {
      group("fetch", () {
        test("works", () async {
          var query = EventsQuery()
            ..startTime = DateTime.now().subtract(Duration(days: 1));
          var results = await query.fetch();
          expect(results.length, isNot(0));
        });
      });
    });
  });
}
