import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
import UserModel from 'gistr-app/models/user';

moduleForModel('user', 'Unit - User Model', {
  needs: ['model:user', 'model:sentence']
});

test('it exists', function() {
  expect(1);
  var user = this.subject({ nickname: 'joe' });
  ok(user instanceof UserModel);
});

test('relationships are good', function() {
  expect(2);
  var User = this.store().modelFor('user'),
      sentences = Ember.get(User, 'relationshipsByName').get('sentences');

  equal(sentences.key, 'sentences');
  equal(sentences.kind, 'hasMany');
});
