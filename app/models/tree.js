import DS from 'ember-data';

var Tree = DS.Model.extend({
  created: DS.attr('date'),
  root: DS.belongsTo('sentence', { async: true }),
  profile: DS.belongsTo('profile', {
    inverse: 'created_trees',
    async: true
  }),
  sentences: DS.hasMany('sentence', { async: true }),
  profiles: DS.hasMany('profile', {
    inverse: 'all_trees',
    async: true
  }),
  untouched: DS.attr('boolean')
});

// FIXME: use mocks instead of fixtures
Tree.reopenClass({
  FIXTURES: [
  ]
});

export default Tree;
