import { test, moduleFor } from 'ember-qunit';


import PlayRoute from 'appkit/routes/play';

moduleFor('route:play', "Unit - PlayRoute");

test("it exists", function() {
  ok(this.subject() instanceof PlayRoute);
});
