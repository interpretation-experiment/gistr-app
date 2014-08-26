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
  controller.set('lastNow', Date.now() - 50 * 1000);  // now - 50ms
  controller.set('countdownPrec', 1000);
  controller._setCountdown = function(value) {
    ok(value > 949);
    ok(value < 951);
  };
  controller._reschedule = function() {
    ok(true);
  };
  controller._updateCountdown();
});
