import { test, moduleFor } from 'ember-qunit';


import PlayIndexRoute from 'gistr-app/routes/play/index';

moduleFor('route:play/index', "Unit - PlayIndexRoute");

test("it exists", function() {
  expect(1);
  ok(this.subject() instanceof PlayIndexRoute);
});
