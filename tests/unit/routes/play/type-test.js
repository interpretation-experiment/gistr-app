import { test, moduleFor } from 'ember-qunit';


import PlayTypeRoute from 'gistr-app/routes/play/type';
import TracingRoute from 'gistr-app/routes/tracing-route';

moduleFor('route:play/type', "Unit - PlayTypeRoute");

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayTypeRoute);
  ok(this.subject() instanceof TracingRoute);
});
