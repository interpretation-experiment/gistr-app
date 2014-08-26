import { test, moduleFor } from 'ember-qunit';


import PlayReadController from 'appkit/controllers/play/read';

moduleFor('controller:play/read', "Unit - PlayReadController");

test("it exists", function() {
  expect(1);
  ok(this.subject() instanceof PlayReadController);
});

test("startCountdown calls the right method", function() {
  expect(2);

  var controller = this.subject();
  controller._startCountdown = function(route, callback) {
    equal(route, 'dummy-route');
    equal(callback, 'dummy-callback');
  };

  controller.send('startCountdown', 'dummy-route', 'dummy-callback');
});

test("cancelCountdown calls the right method", function() {
  expect(1);

  var controller = this.subject();
  controller._cancelCountdown = function() {
    ok(true);
  };

  controller.send('cancelCountdown');
});

test("_startCountdown starts transitionTimer with proper delay, " +
     "sets countdown, and reschedules", function() {
  expect(6);

  var controller = this.subject(),
      context = { goodContext: true };

  // Shorten transitionTimer to speed up test
  controller.duration = 0.25;

  controller._setCountdown = function(value) {
    equal(value, 0.25);
  };
  controller._reschedule = function() {
    ok(true);
  };
  controller.set('content', {});
  var now = Date.now();

  return new Ember.RSVP.Promise(function(resolve, reject) {
    var callback = function() {
      // Callback is called
      ok(true);
      // called in the right context
      ok(this.goodContext);
      // less than 5ms difference, allowing for runtime imprecisions
      ok(Math.abs(Date.now() - now - 250) < 5);
      // resolve promise to close test
      resolve(true);
    };

    controller._startCountdown(context, callback);
    ok(!!controller.get('transitionTimer'));
  });
});

test("_updateCountdown sets correct new countdown and reschedules", function() {
  expect(2);

  var controller = this.subject();

  controller.set('content', {});
  controller.set('lastNow', Date.now() - 50);  // now - 50ms
  controller.set('countdownPrec', 1);
  controller._setCountdown = function(value) {
    // less than 5ms difference, allowing for runtime imprecisions
    ok(Math.abs(value - 0.95) < 0.005);
  };
  controller._reschedule = function() {
    ok(true);
  };
  controller._updateCountdown();
});

test("_cancelCountdown cancels transitionTimer", function() {
  expect(2);

  var controller = this.subject(),
      transitionTimerHasRun = false;

  controller.set('content', {});
  // Set a transitionTimer that fails the test
  var transitionTimer = Ember.run.later(this, function() {
    transitionTimerHasRun = true;
  }, 10);
  controller.set('transitionTimer', transitionTimer);

  return new Ember.RSVP.Promise(function(resolve, reject) {
    // Set a timer to check transitionTimer was cancelled
    Ember.run.later(this, function() {
      if (transitionTimerHasRun) {
        reject('transitionTimer should be cancelled');
      } else {
        resolve('transitionTimer was cancelled');
        ok(true);
      }
    }, 20);

    // launch cancellation of timer
    controller._cancelCountdown();
    equal(controller.get('transitionTimer'), undefined);
  });
});

test("_cancelCountdown cancels renderTimer", function() {
  expect(2);

  var controller = this.subject(),
      renderTimerHasRun = false;

  controller.set('content', {});
  // Set a renderTimer that fails the test
  var renderTimer = Ember.run.later(this, function() {
    renderTimerHasRun = true;
  }, 10);
  controller.set('renderTimer', renderTimer);

  return new Ember.RSVP.Promise(function(resolve, reject) {
    // Set a timer to check renderTimer was cancelled
    Ember.run.later(this, function() {
      if (renderTimerHasRun) {
        reject('renderTimer should be cancelled');
      } else {
        resolve('renderTimer was cancelled');
        ok(true);
      }
    }, 20);

    // launch cancellation of timer
    controller._cancelCountdown();
    equal(controller.get('renderTimer'), undefined);
  });
});

test("_setCountdown sets new countdown value", function() {
  expect(2);

  var controller = this.subject();

  // Refine precision
  controller.set('content', {});
  controller.set('precision', 4);

  controller._setCountdown(1.2);
  equal(controller.get('countdownPrec'), 1.2);
  equal(controller.get('countdown'), 1.25);
});

test("_reschedule sets lastNow and launches _updateCountdown with proper delay, " +
     "iff countdownPrec > 0", function() {
  expect(5);

  var controller = this.subject();

  // Set negative countdownPrec
  controller.set('content', {});
  controller.set('countdownPrec', -1);

  // Nothing happens
  controller._reschedule();
  equal(controller.get('lastNow'), undefined);
  equal(controller.get('renderTimer'), undefined);

  // Set new positive countdownPrec, and refine precision to speed up test
  controller.set('countdownPrec', 1);
  controller.set('precision', 4);

  // It sets lastNow and calls _updateCountdown, setting renderTimer

  var now = Date.now(),
      updateCountdownHasRun = false;
  controller._updateCountdown = function() {
    updateCountdownHasRun = true;
    // less than 5ms difference, allowing for runtime imprecisions
    ok(Math.abs(Date.now() - now - 250) < 5);
    // less than 5ms difference, allowing for runtime imprecisions
    ok(Math.abs(controller.get('lastNow') - now) < 5);
  };

  return new Ember.RSVP.Promise(function(resolve, reject) {
    Ember.run.later(this, function() {
      if (updateCountdownHasRun) {
        resolve('_updateCountdown has run');
      } else {
        reject('_updateCountdown should have run');
      }
    }, 300);

    controller._reschedule();
    ok(!!controller.get('renderTimer'));
  });
});
