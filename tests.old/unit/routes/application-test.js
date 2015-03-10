import { test, moduleFor } from 'ember-qunit';


import ApplicationRoute from 'gistr/routes/application';

moduleFor('route:application', 'Unit - ApplicationRoute');

test('it exists', function() {
  expect(1);
  ok(this.subject() instanceof ApplicationRoute);
});


