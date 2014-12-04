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
  clock.tick(100);
  controller._updateCountdown();
  equal(controller.get('lastNow'), 100);
  equal(controller.get('countdownPrecise'), 0.9);
  equal(controller.get('countdown'), 1);
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

//test("_cancelCountdown cancels renderTimer", function() {
  //expect(2);

  //var controller = this.subject(),
      //renderTimerHasRun = false;

  //controller.set('content', {});
  //// Set a renderTimer that fails the test
  //var renderTimer = Ember.run.later(this, function() {
    //renderTimerHasRun = true;
  //}, 10);
  //controller.set('renderTimer', renderTimer);

  //return new Ember.RSVP.Promise(function(resolve, reject) {
    //// Set a timer to check renderTimer was cancelled
    //Ember.run.later(this, function() {
      //if (renderTimerHasRun) {
        //reject('renderTimer should be cancelled');
      //} else {
        //resolve('renderTimer was cancelled');
        //ok(true);
      //}
    //}, 20);

    //// launch cancellation of timer
    //controller._cancelCountdown();
    //equal(controller.get('renderTimer'), undefined);
  //});
//});

//test("_setCountdown sets new countdown value", function() {
  //expect(2);

  //var controller = this.subject();

  //// Refine precision
  //controller.set('content', {});
  //controller.set('precision', 4);

  //controller._setCountdown(1.2);
  //equal(controller.get('countdownPrec'), 1.2);
  //equal(controller.get('countdown'), 1.25);
//});

//test("_reschedule sets lastNow and launches _updateCountdown with proper delay, " +
     //"iff countdownPrec > 0", function() {
  //expect(5);

  //var controller = this.subject();

  //// Set negative countdownPrec
  //controller.set('content', {});
  //controller.set('countdownPrec', -1);

  //// Nothing happens
  //controller._reschedule();
  //equal(controller.get('lastNow'), undefined);
  //equal(controller.get('renderTimer'), undefined);

  //// Set new positive countdownPrec, and refine precision to speed up test
  //controller.set('countdownPrec', 1);
  //controller.set('precision', 4);

  //// It sets lastNow and calls _updateCountdown, setting renderTimer

  //var now = Date.now(),
      //updateCountdownHasRun = false;
  //controller._updateCountdown = function() {
    //updateCountdownHasRun = true;
    //// less than 5ms difference, allowing for runtime imprecisions
    //ok(Math.abs(Date.now() - now - 250) < 5);
    //// less than 5ms difference, allowing for runtime imprecisions
    //ok(Math.abs(controller.get('lastNow') - now) < 5);
  //};

  //return new Ember.RSVP.Promise(function(resolve, reject) {
    //Ember.run.later(this, function() {
      //if (updateCountdownHasRun) {
        //resolve('_updateCountdown has run');
      //} else {
        //reject('_updateCountdown should have run');
      //}
    //}, 300);

    //controller._reschedule();
    //ok(!!controller.get('renderTimer'));
  //});
//});
