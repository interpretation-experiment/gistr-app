var User = DS.Model.extend({
  nickname: DS.attr('string'),
  sentences: DS.hasMany('sentence')
});

export default User;
