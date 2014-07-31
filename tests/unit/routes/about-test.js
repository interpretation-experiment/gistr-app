import { test, moduleFor } from 'ember-qunit';


import AboutRoute from 'appkit/routes/about';

moduleFor('route:about', "Unit - AboutRoute");

test("it exists", function() {
  ok(this.subject() instanceof AboutRoute);
});
