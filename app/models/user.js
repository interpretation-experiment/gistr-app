// FIXME: Not unit-tested, because runs into errors. See 'test-models' branch.
var User = DS.Model.extend({
  nickname: DS.attr('string'),
  sentences: DS.hasMany('sentence')
});

// FIXME: use mocks instead of fixtures
User.reopenClass({
  FIXTURES: [
    { id: '1', nickname: 'jane', sentences: ['1', '5'] },
    { id: '2', nickname: 'neil', sentences: ['2', '4'] },
    { id: '3', nickname: 'chris', sentences: ['3', '6'] }
  ]
});

export default User;
