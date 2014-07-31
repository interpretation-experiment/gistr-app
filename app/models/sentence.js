var Sentence = DS.Model.extend({
  author: DS.belongsTo('user'),
  // TODO: add date
  // TODO: add location
  from: DS.belongsTo('sentence'),
  children: DS.hasMany('sentence'),
  text: DS.attr('string')
});

export default Sentence;
