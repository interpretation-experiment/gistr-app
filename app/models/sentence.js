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
  language: DS.attr('string'),

  /*
   * Unused properties
   */
  url: DS.attr('string'),
  tree_url: DS.attr('string'),
  profile_url: DS.attr('string'),
  profile_username: DS.attr('string'),
  parent_url: DS.attr('string'),
});
