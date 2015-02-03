import DS from 'ember-data';

var Tree = DS.Model.extend({
  sentences: DS.hasMany('sentence', { async: true }),
  profiles: DS.hasMany('profile', { async: true })
});

// FIXME: use mocks instead of fixtures
Tree.reopenClass({
  FIXTURES: [
  ]
});

export default Tree;
