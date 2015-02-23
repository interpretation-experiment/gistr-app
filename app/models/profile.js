import DS from 'ember-data';


export default DS.Model.extend({
  created: DS.attr('date'),
  user: DS.belongsTo('user', { async: true }),
  trees: DS.hasMany('tree', { async: true }),
  sentences: DS.hasMany('sentence', { async: true }),
  suggestionCredit: DS.attr('number'),
  mothertongue: DS.attr('string'),
  untouchedTreesCount: DS.attr('number')
});
