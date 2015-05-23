import DS from 'ember-data';


export default DS.Model.extend({
  user: DS.belongsTo('user'),
  email: DS.attr('string'),
  verified: DS.attr('boolean'),
  primary: DS.attr('boolean')
});
