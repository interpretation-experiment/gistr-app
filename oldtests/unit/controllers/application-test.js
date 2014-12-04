import { test, moduleFor } from 'ember-qunit';


import ApplicationController from 'gistr-app/controllers/application';

moduleFor('controller:application', 'Unit - ApplicationController');

test('it exists', function() {
  expect(1);
  ok(this.subject() instanceof ApplicationController);
});

test('#netstatus', function() {
  expect(3);

  var controller = this.subject();

  equal(controller.get('netstatus'), 'checking');

  controller.setOnline();
  equal(controller.get('netstatus'), 'online');

  controller.setOffline();
  equal(controller.get('netstatus'), 'offline');
});
