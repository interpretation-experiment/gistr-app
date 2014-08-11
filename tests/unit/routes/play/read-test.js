import { test, moduleFor } from 'ember-qunit';


import PlayReadRoute from 'appkit/routes/play/read';
import TracingRoute from 'appkit/routes/tracing-route';

moduleFor('route:play/read', "Unit - PlayReadRoute", {
  needs: ['controller:play/read']
});

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayReadRoute);
  ok(this.subject() instanceof TracingRoute);
});

test("setupController sets up the model", function() {
  expect(1);
  var sentence = { text: 'dummy text' },
      route = this.subject(),
      controller = route.controllerFor('play/read');

  // Neutralize the countdown starting
  controller.reopen({
    actions: {
      startCountdown: function(route, callback) { }
    }
  });

  route.setupController(controller, sentence);
  deepEqual(controller.get('model'), sentence);
});

test("setupController sends startCountdown to controller", function() {
  expect(2);
  var route = this.subject(),
      controller = route.controllerFor('play/read');

  controller.reopen({
    actions: {
      startCountdown: function(route, callback) {
        this.countdownStarted = true;
      }
    }
  });

  equal(controller.get('countdownStarted'), undefined);
  route.setupController(controller);
  equal(controller.get('countdownStarted'), true);
});

test("setupController ultimately transitions to play.ok", function() {
  expect(2);
  var route = this.subject(),
      controller = route.controllerFor('play/read');

  controller.reopen({
    actions: {
      startCountdown: function(route, callback) {
        callback.call(route);
      }
    }
  });

  route.transitionTo = function(targetName) {
    this.transitioningTo = targetName;
  };

  equal(route.get('transitioningTo'), undefined);
  route.setupController(controller);
  equal(route.get('transitioningTo'), 'play.ok');
});

// TODO: test willTransition in acceptance tests
// Testing willTransition action goes into acceptance tests, since it ultimately
// needs a full-blown router.

test("_willTransition sends cancelCountdown to controller", function() {
  expect(2);
  var route = this.subject(),
      controller = route.controllerFor('play/read');

  // Manually set controller on route since it doesn't get injected
  route.controller = controller;

  controller.reopen({
    actions: {
      cancelCountdown: function() {
        this.countdownCancelled = true;
      }
    }
  });

  equal(controller.get('countdownCancelled'), undefined);
  route._willTransition({});
  equal(controller.get('countdownCancelled'), true);
});

test("_willTransition sets originName in transition", function() {
  expect(1);
  var transition = {},
      route = this.subject(),
      controller = route.controllerFor('play/read');

  route.routeName = 'dummy-route';

  // Manually set controller on route since it doesn't get injected
  route.controller = controller;

  route._willTransition(transition);
  deepEqual(transition, { originName: 'dummy-route' });
});
