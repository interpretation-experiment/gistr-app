import { test, moduleFor } from 'ember-qunit';


import TracingRoute from 'gistr-app/routes/tracing-route';

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

test("it redirects if origin is unauthorized", function() {
  expect(1);

  var tracingRoute = this.subject();
  var transition = {};
  // An unauthorized route
  transition.originName = 'unauthed-route';
  tracingRoute.authorizedOrigins = ['authed-route1', 'authed-route-2'];
  tracingRoute.unauthorizedOriginRedirect = 'redirect-route';
  // Test that this variable will be set
  this.hasTransitioned = false;
  tracingRoute.transitionTo = function() {
    this.hasTransitioned = true;
  };
  tracingRoute.beforeModel(transition);
  equal(tracingRoute.hasTransitioned, true);
});

test("it doesn't redirect if origin is authorized", function() {
  expect(1);

  var tracingRoute = this.subject();
  var transition = {};
  // An authorized route
  transition.originName = 'authed-route1';
  tracingRoute.authorizedOrigins = ['authed-route1', 'authed-route-2'];
  tracingRoute.unauthorizedOriginRedirect = 'redirect-route';
  // Test for that this variable is not changed
  tracingRoute.hasNotTransitioned = true;
  tracingRoute.transitionTo = function() {
    this.hasNotTransitioned = false;
  };
  tracingRoute.beforeModel(transition);
  equal(tracingRoute.hasNotTransitioned, true);
});

test("redirects and non-redirects also work when origin is undefined", function() {
  expect(2);

  var tracingRoute = this.subject();
  var transition = {};
  // Dont' define transition.originName
  tracingRoute.authorizedOrigins = ['authed-route1', undefined];
  tracingRoute.unauthorizedOriginRedirect = 'redirect-route';
  // Test for that this variable is not changed
  tracingRoute.hasNotTransitioned = true;
  tracingRoute.transitionTo = function() {
    this.hasNotTransitioned = false;
  };
  tracingRoute.beforeModel(transition);
  equal(tracingRoute.hasNotTransitioned, true);

  // undefined is now out of authorizedOrigins
  tracingRoute.authorizedOrigins = ['authed-route1', 'authed-route2'];
  // Test that this variable will be set
  this.hasTransitioned = false;
  tracingRoute.transitionTo = function() {
    this.hasTransitioned = true;
  };
  tracingRoute.beforeModel(transition);
  equal(tracingRoute.hasTransitioned, true);
});

test("it ignores origin and redirect if no authorizedOrigins are defined", function() {
  expect(1);

  var tracingRoute = this.subject();
  var transition = {};
  // An unauthorized route
  transition.originName = 'unauthed-route';
  // Don't define authorizedOrigins
  tracingRoute.unauthorizedOriginRedirect = 'redirect-route';
  // Test for that this variable is not changed
  tracingRoute.hasNotTransitioned = true;
  tracingRoute.transitionTo = function() {
    this.hasNotTransitioned = false;
  };
  tracingRoute.beforeModel(transition);
  equal(tracingRoute.hasNotTransitioned, true);
});

test("it always throws an error if authorizedOrigins is defined but not a list " +
     "(but not if the list is empty)", function() {
  expect(2);

  var tracingRoute = this.subject();
  var transition = {};
  // An unauthorized route
  transition.originName = 'unauthed-route';
  tracingRoute.authorizedOrigins = 'not-a-list';
  tracingRoute.unauthorizedOriginRedirect = 'redirect-route';
  raises(function() {
    tracingRoute.beforeModel(transition);
  }, "has defined 'authorizedOrigins' but it's not a list");

  tracingRoute.authorizedOrigins = [];
  // Test that this variable will be set
  this.hasTransitioned = false;
  tracingRoute.transitionTo = function() {
    this.hasTransitioned = true;
  };
  tracingRoute.beforeModel(transition);
  equal(tracingRoute.hasTransitioned, true);
});

test("it always throws an error if authorizedOrigins is defined " +
     "without unauthorizedOriginRedirect", function() {
  expect(2);

  var tracingRoute = this.subject();
  var transition = {};
  // An unauthorized route
  transition.originName = 'unauthed-route';
  tracingRoute.authorizedOrigins = ['authed-route1', 'authed-route2'];
  // Don't define unauthorizedOriginRedirect
  raises(function() {
    tracingRoute.beforeModel(transition);
  }, "has defined 'authorizedOrigins' but no 'unauthorizedOriginRedirect'");

  // An authorized route
  transition.originName = 'authed-route1';
  raises(function() {
    tracingRoute.beforeModel(transition);
  }, "has defined 'authorizedOrigins' but no 'unauthorizedOriginRedirect'");
});
