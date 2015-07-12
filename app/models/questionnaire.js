import DS from 'ember-data';


export default DS.Model.extend({
  created: DS.attr('date'),
  profile: DS.belongsTo('profile', { async: true }),

  age: DS.attr('number'),
  gender: DS.attr('string'),
  informed: DS.attr('boolean'),
  informedHow: DS.attr('string'),
  informedWhat: DS.attr('string'),
  jobType: DS.attr('string'),
  jobFreetext: DS.attr('string'),

  /*
   * Unused properties
   */
  url: DS.attr('string'),
  profileUrl: DS.attr('string'),
});
