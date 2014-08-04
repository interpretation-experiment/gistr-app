import { test, moduleFor } from 'ember-qunit';


import PlayReadRoute from 'appkit/routes/play/read';
import TracingRoute from 'appkit/routes/tracing-route';

moduleFor('route:play/read', "Unit - PlayReadRoute");

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayReadRoute);
  ok(this.subject() instanceof TracingRoute);
});
