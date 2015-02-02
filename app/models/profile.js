import DS from 'ember-data';

var Profile = DS.Model.extend({
  created: DS.attr('date'),
  user: DS.belongsTo('user', { async: true }),
  sentences: DS.hasMany('sentence', { async: true })
});

// FIXME: use mocks instead of fixtures
Profile.reopenClass({
  FIXTURES: [
  ]
});

export default Profile;
