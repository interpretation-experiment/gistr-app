import { test, moduleFor } from 'ember-qunit';


import PlayOkRoute from 'appkit/routes/play/ok';
import TracingRoute from 'appkit/routes/tracing-route';

moduleFor('route:play/ok', "Unit - PlayOkRoute");

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayOkRoute);
  ok(this.subject() instanceof TracingRoute);
});
