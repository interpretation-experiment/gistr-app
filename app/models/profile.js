import Ember from 'ember';
import DS from 'ember-data';


export default DS.Model.extend({
  userUsername: DS.attr('string'),
  created: DS.attr('date'),
  trainedReformulations: DS.attr('boolean'),
  user: DS.belongsTo('user', { async: true }),
  trees: DS.hasMany('tree', { async: true }),
  treesCount: DS.attr('number'),
  sentences: DS.hasMany('sentence', { async: true }),
  sentencesCount: DS.attr('number'),
  reformulationsCount: DS.attr('number'),
  suggestionCredit: DS.attr('number'),
  nextCreditIn: DS.attr('number'),
  mothertongue: DS.attr('string'),
  availableTreesCounts: DS.attr('object'),

  /*
   * Unused properties
   */
  url: DS.attr('string'),
  userUrl: DS.attr('string'),

  /*
   * Computed properties
   */
  lifecycle: Ember.inject.service(),
  availableTreesBucket: function() {
    var bucket = this.get('lifecycle.bucket');
    return this.get('availableTreesCounts')[bucket];
  }.property('lifecycle.bucket', 'availableTreesCounts')
});
