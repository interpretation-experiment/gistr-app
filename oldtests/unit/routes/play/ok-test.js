import { test, moduleFor } from 'ember-qunit';


import PlayOkRoute from 'gistr-app/routes/play/ok';
import TracingRoute from 'gistr-app/routes/tracing-route';

moduleFor('route:play/ok', "Unit - PlayOkRoute");

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayOkRoute);
  ok(this.subject() instanceof TracingRoute);
});
