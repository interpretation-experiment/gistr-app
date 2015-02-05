import DS from 'ember-data';

var Sentence = DS.Model.extend({
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
  text: DS.attr('string')
});

// FIXME: use mocks instead of fixtures
Sentence.reopenClass({
  FIXTURES: [
    //{ id: '1', author: '1', from: null, children: ['2', '3'], text: 'Some first sentence' },
    //{ id: '2', author: '2', from: '1', children: [], text: 'Some first phrase' },
    //{ id: '3', author: '3', from: '1', children: [], text: 'Some first plot' },
    //{ id: '4', author: '2', from: null, children: ['5'], text: 'Well now this is nice' },
    //{ id: '5', author: '1', from: '4', children: ['6'], text: 'Well now this is neat' },
    //{ id: '6', author: '3', from: '5', children: [], text: 'Will you come to eat' }
  ]
});

export default Sentence;
