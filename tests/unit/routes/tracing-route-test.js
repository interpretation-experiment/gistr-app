import { test, moduleFor } from 'ember-qunit';


import TracingRoute from 'appkit/routes/tracing-route';

moduleFor('route:tracing-route', "Unit - TracingRoute");

test("it exists", function() {
  expect(1);
  ok(this.subject() instanceof TracingRoute);
});

test("it decorates an outgoing transition", function() {
  expect(2);
  var dummyTransition = {};
  this.subject().set('routeName', 'dummy-route');
  equal(dummyTransition.originName, undefined);
  this.subject()._willTransition(dummyTransition);
  equal(dummyTransition.originName, 'dummy-route');
});
