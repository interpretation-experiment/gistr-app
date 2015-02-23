import DS from 'ember-data';


export default DS.Model.extend({
  isStaff: DS.attr('boolean'),
  isActive: DS.attr('boolean'),
  email: DS.attr('string'),
  username: DS.attr('string'),
  profile: DS.belongsTo('profile')  // not async since it's nested
});
