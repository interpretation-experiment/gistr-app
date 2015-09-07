import DS from 'ember-data';


export default DS.Model.extend({
  created: DS.attr('date'),
  profile: DS.belongsTo('profile', { async: true }),
  score: DS.attr('number'),
  span: DS.attr('number'),

  /*
   * Unused properties
   */
  url: DS.attr('string'),
  profileUrl: DS.attr('string'),
});
