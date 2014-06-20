import { test, moduleFor } from 'ember-qunit';


import ApplicationController from 'appkit/controllers/application';

moduleFor('controller:application', 'Unit - ApplicationController');

test('it exists', function() {
  ok(this.subject() instanceof ApplicationController);
});

test('#netstatus', function() {
  equal(this.subject().get('netstatus'), 'checking');
  this.subject().setOnline();
  equal(this.subject().get('netstatus'), 'online');
  this.subject().setOffline();
  equal(this.subject().get('netstatus'), 'offline');
  var self = this;
  this.subject().updateNetstatus().always(function () {
    equal(self.subject().get('netstatus'), 'online');
  });
});
