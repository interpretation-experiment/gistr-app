import { test, moduleFor } from 'ember-qunit';


import PlayTypeRoute from 'appkit/routes/play/type';
import TracingRoute from 'appkit/routes/tracing-route';

moduleFor('route:play/type', "Unit - PlayTypeRoute");

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayTypeRoute);
  ok(this.subject() instanceof TracingRoute);
});
