import DS from 'ember-data';


export default DS.Model.extend({
  created: DS.attr('date'),
  root: DS.belongsTo('sentence'),  // not async since it's nested
  sentences: DS.hasMany('sentence', { async: true }),
  profiles: DS.hasMany('profile', { async: true }),
  networkEdges: DS.attr('array')
});
