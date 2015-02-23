import DS from 'ember-data';


export default DS.Model.extend({
  created: DS.attr('date'),
  tree: DS.belongsTo('tree', {
    inverse: 'sentences',
    async: true
  }),
  profile: DS.belongsTo('profile', { async: true }),
  parent: DS.belongsTo('sentence', {
    inverse: 'children',
    async: true
  }),
  children: DS.hasMany('sentence', {
    inverse: 'parent',
    async: true
  }),
  text: DS.attr('string'),
  language: DS.attr('string')
});
