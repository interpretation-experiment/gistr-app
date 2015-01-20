import { test, moduleFor } from 'ember-qunit';
import Ember from 'ember';

import PlayReadController from 'gistr/controllers/play/read';

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

test("_startCountdown starts transitionTimer and renderInterval with proper delay, " +
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
  ok(!!controller.get('renderInterval'));
  equal(controller._updateCountdown.callCount, 1);

  // Tick to just before the timer triggers
  clock.tick(duration * 1000 - 1);
  equal(callback.callCount, 0);
  equal(controller._updateCountdown.callCount, duration * precision);

  // Trigger the timer
  clock.tick(1);
  ok(callback.calledOnce);
});

test("_startCountdown sets values for lastNow and preciseCountdown even " +
     "if set", function() {
  expect(2);

  var controller = this.subject();

  // Manually set content since it's not injected
  controller.set('content', {});

  controller.set('lastNow', 1000);
  controller.set('preciseCountdown', controller.get('duration') + 10);

  controller._startCountdown();
  equal(controller.get('lastNow'), 0);
  equal(controller.get('preciseCountdown'), controller.get('duration'));
});

test("_updateCountdown sets correct lastNow, preciseCountdown, " +
     "and countdown", function() {
  expect(3);

  var controller = this.subject();

  // Manually set content since it's not injected
  controller.set('content', {});

  controller.set('lastNow', 0);
  controller.set('preciseCountdown', 1);
  controller.set('precision', 4);
  clock.tick(400);
  controller._updateCountdown();
  equal(controller.get('lastNow'), 400);
  equal(controller.get('preciseCountdown'), 0.6);
  equal(controller.get('countdown'), 0.75);
});

test("_cancelCountdown cancels transitionTimer and renderInterval", function() {
  expect(6);

  var controller = this.subject(),
      transitionCallback = sinon.spy(),
      renderCallback = sinon.spy();

  // Manually set content since it's not injected
  controller.set('content', {});

  // Set a timers that should not run
  var transitionTimer = setTimeout(Ember.run.bind(this, transitionCallback), 20);
  controller.set('transitionTimer', transitionTimer);
  var renderInterval = setInterval(Ember.run.bind(this, renderCallback), 5);
  controller.set('renderInterval', renderInterval);

  // Tick halfway through and cancel timer
  clock.tick(12);
  equal(transitionCallback.callCount, 0);
  equal(renderCallback.callCount, 2);
  controller._cancelCountdown();

  // Tick all the way through and over
  clock.tick(12);
  equal(transitionCallback.callCount, 0);
  equal(renderCallback.callCount, 2);
  equal(controller.get('transitionTimer'), undefined);
  equal(controller.get('renderInterval'), undefined);
});
