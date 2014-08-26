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

test("_startCountdown starts transitionTimer, sets countdown, and reschedules",
     function() {
  expect(5);

  var controller = this.subject(),
      context = { goodContext: true };

  return new Ember.RSVP.Promise(function(resolve, reject) {
    var callback = function() {
      // Callback is called
      ok(true);
      // called in the right context
      ok(this.goodContext);
      // resolve promise to close test
      resolve(true);
    };

    // Shorten transitionTimer
    controller.duration = 1;
    controller._setCountdown = function(value) {
      equal(value, 1);
    };
    controller._reschedule = function() {
      ok(true);
    };
    controller.set('content', {});

    controller._startCountdown(context, callback);
    ok(!!controller.get('transitionTimer'));
  });
});

test("_updateCountdown sets correct new countdown and reschedules", function() {
  expect(3);

  var controller = this.subject();

  controller.set('content', {});
  controller.set('lastNow', Date.now() - 50);  // now - 50ms
  controller.set('countdownPrec', 1);
  controller._setCountdown = function(value) {
    ok(value > 0.940);
    ok(value < 0.960);
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

  return new Ember.RSVP.Promise(function(resolve, reject) {
    controller.set('content', {});
    // Set a transitionTimer that fails the test
    var transitionTimer = Ember.run.later(this, function() {
      transitionTimerHasRun = true;
    }, 10);
    controller.set('transitionTimer', transitionTimer);

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

  return new Ember.RSVP.Promise(function(resolve, reject) {
    controller.set('content', {});
    // Set a renderTimer that fails the test
    var renderTimer = Ember.run.later(this, function() {
      renderTimerHasRun = true;
    }, 10);
    controller.set('renderTimer', renderTimer);

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

test("_setCountdown sets new countdown", function() {
  expect(2);

  var controller = this.subject();

  // Refine precision
  controller.set('content', {});
  controller.set('precision', 4);

  controller._setCountdown(1.2);
  equal(controller.get('countdownPrec'), 1.2);
  equal(controller.get('countdown'), 1.25);
});
