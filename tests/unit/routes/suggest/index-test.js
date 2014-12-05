import { test, moduleFor } from 'ember-qunit';
import SuggestIndexRoute from 'gistr-app/routes/suggest/index';

moduleFor('route:suggest/index', "Unit - SuggestIndexRoute");

test("it exists", function() {
  expect(1);
  ok(this.subject() instanceof SuggestIndexRoute);
});
