import DS from 'ember-data';

var Profile = DS.Model.extend({
  created: DS.attr('date'),
  user: DS.belongsTo('user', { async: true }),
  created_trees: DS.hasMany('tree', { async: true }),
  all_trees: DS.hasMany('tree', { async: true }),
  sentences: DS.hasMany('sentence', { async: true }),
  suggestion_credit: DS.attr('number')
});

// FIXME: use mocks instead of fixtures
Profile.reopenClass({
  FIXTURES: [
  ]
});

export default Profile;
