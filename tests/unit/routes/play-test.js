import { test, moduleFor } from 'ember-qunit';


import PlayRoute from 'appkit/routes/play';

moduleFor('route:play', "Unit - PlayRoute");

test("it exists", function() {
  ok(this.subject() instanceof PlayRoute);
});

test("#model", function() {
  deepEqual(this.subject().model(), {
    id: '1',
    author: '1',
    from: null,
    children: [],
    text: 'Some first sentence'
  });
});
