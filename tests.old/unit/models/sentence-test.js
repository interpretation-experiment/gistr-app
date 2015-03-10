import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
import SentenceModel from 'gistr/models/sentence';

moduleForModel('sentence', 'Unit - Sentence Model', {
  needs: ['model:user', 'model:sentence']
});

test('it exists', function() {
  expect(1);
  var sentence = this.subject({ text: 'Whoey gist away' });
  ok(sentence instanceof SentenceModel);
});

test('relationships are good', function() {
  expect(8);
  var Sentence = this.store().modelFor('sentence'),
      relationships = Ember.get(Sentence, 'relationshipsByName'),
      author = relationships.get('author'),
      parent = relationships.get('parent'),
      children = relationships.get('children');

  equal(author.key, 'author');
  equal(author.kind, 'belongsTo');
  equal(parent.key, 'parent');
  equal(parent.kind, 'belongsTo');
  equal(parent.options.inverse, 'children');
  equal(children.key, 'children');
  equal(children.kind, 'hasMany');
  equal(children.options.inverse, 'parent');
});
