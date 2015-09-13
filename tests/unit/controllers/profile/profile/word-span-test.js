import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';

moduleFor('controller:profile/profile/word-span', {
  // Specify the other units that are required for this test.
  // needs: ['controller:foo']
});

// Replace this with your real tests.
test('it exists', function(assert) {
  var controller = this.subject();
  assert.ok(controller);
});

test('span is properly computed', function(assert) {
  assert.expect(6);

  var controller = this.subject();

  // The last size to have the minimum acceptable level (2/3) is the span
  Ember.run(function() {
    controller.set('spanStats', {
      3: [true, true, true],
      4: [true, false, false],
      5: [true, false, false],
    });
    assert.equal(controller.computeSpan(), 3);
    assert.equal(controller.get('span'), 3);

    controller.set('spanStats', {
      3: [true, true, true],
      4: [true, true, false],
      5: [true, false, false],
    });
    assert.equal(controller.computeSpan(), 4);
    assert.equal(controller.get('span'), 4);

    controller.set('spanStats', {
      3: [true, true, true],
      4: [true, true, true],
      5: [true, true, false],
      6: [true, false, true],
      7: [true, false, false],
    });
    assert.equal(controller.computeSpan(), 6);
    assert.equal(controller.get('span'), 6);
  });
});
