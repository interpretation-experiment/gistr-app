// WONTFIX: Not unit-tested, because runs into errors. See 'test-models' branch.
var Sentence = DS.Model.extend({
  author: DS.belongsTo('user'),
  // TODO: add date
  // TODO: add location
  from: DS.belongsTo('sentence', {
    inverse: 'children'
  }),
  children: DS.hasMany('sentence', {
    inverse: 'from'
  }),
  text: DS.attr('string')
});

Sentence.reopenClass({
  FIXTURES: [
    { id: '1', author: '1', from: null, children: ['2', '3'], text: 'Some first sentence' },
    { id: '2', author: '2', from: '1', children: [], text: 'Some first phrase' },
    { id: '3', author: '3', from: '1', children: [], text: 'Some first plot' },
    { id: '4', author: '2', from: null, children: ['5'], text: 'Well now this is nice' },
    { id: '5', author: '1', from: '4', children: ['6'], text: 'Well now this is neat' },
    { id: '6', author: '3', from: '5', children: [], text: 'Will you come to eat' }
  ]
});

export default Sentence;
