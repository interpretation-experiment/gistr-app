import DS from 'ember-data';


export default DS.Model.extend({
  created: DS.attr('date'),
  user: DS.belongsTo('user', { async: true }),
  trees: DS.hasMany('tree', { async: true }),
  sentences: DS.hasMany('sentence', { async: true }),
  suggestionCredit: DS.attr('number'),
  nextCreditIn: DS.attr('number'),
  mothertongue: DS.attr('string'),
  untouchedTreesCount: DS.attr('number'),
  availableMothertongueOtherawareTreesCount: DS.attr('number'),

  /*
   * Unused properties
   */
  untouchedDefaultlanguageTreesCount: DS.attr('number'),
  url: DS.attr('string'),
  user_url: DS.attr('string'),
  user_username: DS.attr('string'),
});
