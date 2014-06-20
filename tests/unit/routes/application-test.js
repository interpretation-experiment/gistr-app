import { test, moduleFor } from 'ember-qunit';


import ApplicationRoute from 'appkit/routes/application';

moduleFor('route:application', 'Unit - ApplicationRoute');

test('it exists', function() {
  ok(this.subject() instanceof ApplicationRoute);
});


