import { test, moduleFor } from 'ember-qunit';


import PlayTypeRoute from 'gistr/routes/play/type';
import TracingRoute from 'gistr/routes/tracing-route';

moduleFor('route:play/type', "Unit - PlayTypeRoute");

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayTypeRoute);
  ok(this.subject() instanceof TracingRoute);
});
