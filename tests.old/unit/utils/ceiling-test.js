import { test, moduleFor } from 'ember-qunit';


import ceiling from 'gistr/utils/ceiling';

module("Unit - ceiling");

test("it ceils a number at the right precision", function() {
  expect(4);
  equal(ceiling(1.234, 1), 2);
  equal(ceiling(1.234, 10), 1.3);
  equal(ceiling(1.234, 100), 1.24);
  equal(ceiling(1.234, 1000), 1.234);
});
