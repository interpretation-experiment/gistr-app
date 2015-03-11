import { test, moduleFor } from 'ember-qunit';
import Ember from 'ember';

import PlayReadRoute from 'gistr/routes/play/read';
import TracingRoute from 'gistr/routes/tracing-route';

moduleFor('route:play/read', "Unit - PlayReadRoute", {
  needs: ['controller:play/read']
});

test("it exists and is a tracing route", function() {
  expect(2);
  ok(this.subject() instanceof PlayReadRoute);
  ok(this.subject() instanceof TracingRoute);
});

test("_startCountdown sends startCountdown to controller", function() {
  expect(1);
  var route = this.subject(),
      controller = route.controllerFor('play/read'),
      callback = sinon.spy();

  controller.reopen({
    actions: {
      startCountdown: callback
    }
  });

  route._startCountdown(controller);
  ok(callback.calledOnce);
});

test("_startCountdown ultimately transitions to play.ok", function() {
  expect(1);
  var route = this.subject(),
      controller = route.controllerFor('play/read');

  controller.reopen({
    actions: {
      startCountdown: function(route, callback) {
        callback.call(route);
      }
    }
  });

  route.transitionTo = sinon.spy();

  route._startCountdown(controller);
  ok(route.transitionTo.calledWith('play.ok'));
});

test("_didTransition calls _startCountdown, but not if startCountdown is false", function() {
  expect(1);
  var route = this.subject(),
      controller = route.controllerFor('play/read');

  route._startCountdown = sinon.spy();

  route.startCountdown = false;
  route._didTransition();
  route.startCountdown = true;
  route._didTransition();
  ok(route._startCountdown.calledOnce);
});

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
