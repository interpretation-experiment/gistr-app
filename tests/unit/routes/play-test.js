import { test, moduleFor } from 'ember-qunit';


import PlayRoute from 'appkit/routes/play';

moduleFor('route:play', "Unit - PlayRoute");

test("it exists", function() {
  expect(1);
  ok(this.subject() instanceof PlayRoute);
});
