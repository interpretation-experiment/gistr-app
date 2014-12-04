import { test, moduleFor } from 'ember-qunit';
import Ember from 'ember';

import PlayReadController from 'gistr-app/controllers/play/read';

var clock;

moduleFor('controller:play/read', "Unit - PlayReadController", {
  setup: function() {
    clock = sinon.useFakeTimers();
  },
  teardown: function() {
    clock.restore();
  }
});

test("it exists", function() {
  expect(1);
  ok(this.subject() instanceof PlayReadController);
});

test("startCountdown calls the right method", function() {
  expect(1);

  var controller = this.subject();
  controller._startCountdown = sinon.spy();

  controller.send('startCountdown', 'dummy-route', 'dummy-callback');
  ok(controller._startCountdown.calledWith('dummy-route', 'dummy-callback'));
});

test("cancelCountdown calls the right method", function() {
  expect(1);

  var controller = this.subject();
  controller._cancelCountdown = sinon.spy();

  controller.send('cancelCountdown');
  ok(controller._cancelCountdown.calledOnce);
});

test("_startCountdown starts transitionTimer and renderTimer with proper delay, " +
     "does first countdown update", function() {
  expect(7);

  var controller = this.subject(),
      duration = controller.get('duration'),
      precision = controller.get('precision'),
      context = { goodContext: true },
      callback = sinon.spy(function() {
        // We're called in the right context
        ok(this.goodContext);
      });

  // Manually set content since it's not injected
  controller.set('content', {});

  controller._updateCountdown = sinon.spy();

  controller._startCountdown(context, callback);
  ok(!!controller.get('transitionTimer'));
  ok(!!controller.get('renderTimer'));
  equal(controller._updateCountdown.callCount, 1);

  // Tick to just before the timer triggers
  clock.tick(duration * 1000 - 1);
  equal(callback.callCount, 0);
  equal(controller._updateCountdown.callCount, duration * precision);

  // Trigger the timer
  clock.tick(1);
  ok(callback.calledOnce);
});

test("_updateCountdown gets default values for lastNow " +
     "and countdownPrecise if not set", function() {
  expect(4);

  var controller = this.subject();

  // Manually set content since it's not injected
  controller.set('content', {});

  equal(controller.get('lastNow'), undefined);
  equal(controller.get('countdownPrecise'), undefined);
  controller._updateCountdown();
  equal(controller.get('lastNow'), 0);
  equal(controller.get('countdownPrecise'), controller.get('duration'));
});

test("_updateCountdown sets correct lastNow, countdownPrecise, and countdown", function() {
  expect(3);

  var controller = this.subject();

  // Manually set content since it's not injected
  controller.set('content', {});

  controller.set('lastNow', 0);
  controller.set('countdownPrecise', 1);
  controller.set('precision', 4);
  clock.tick(400);
  controller._updateCountdown();
  equal(controller.get('lastNow'), 400);
  equal(controller.get('countdownPrecise'), 0.6);
  equal(controller.get('countdown'), 0.75);
});

test("_cancelCountdown cancels transitionTimer", function() {
  expect(3);

  var controller = this.subject(),
      callback = sinon.spy();

  // Manually set content since it's not injected
  controller.set('content', {});

  // Set a transitionTimer that should not run
  var transitionTimer = setTimeout(Ember.run.bind(this, callback), 10);
  controller.set('transitionTimer', transitionTimer);

  // Tick halfway through and cancel timer
  clock.tick(5);
  equal(callback.callCount, 0);
  controller._cancelCountdown();

  // Tick all the way through and over
  clock.tick(10);
  equal(callback.callCount, 0);
  equal(controller.get('transitionTimer'), undefined);
});

test("_cancelCountdown cancels renderTimer", function() {
  expect(3);

  var controller = this.subject(),
      callback = sinon.spy();

  // Manually set content since it's not injected
  controller.set('content', {});

  // Set a renderTimer that should not run
  var renderTimer = setInterval(Ember.run.bind(this, callback), 10);
  controller.set('renderTimer', renderTimer);

  // Tick a few cycles
  clock.tick(35);
  equal(callback.callCount, 3);
  controller._cancelCountdown();

  // Tick more cycles
  clock.tick(45);
  equal(callback.callCount, 3);
  equal(controller.get('renderTimer'), undefined);
});
