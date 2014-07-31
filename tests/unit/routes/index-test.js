import { test, moduleFor } from 'ember-qunit';


import IndexRoute from 'appkit/routes/index';

moduleFor('route:index', "Unit - IndexRoute");

test("it exists", function() {
  ok(this.subject() instanceof IndexRoute);
});

test("#model", function() {
  deepEqual(this.subject().model(), ['red', 'yellow', 'blue']);
});
