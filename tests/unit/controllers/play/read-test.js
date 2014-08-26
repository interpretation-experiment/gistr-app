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
