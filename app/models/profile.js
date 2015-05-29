import Ember from 'ember';
import DS from 'ember-data';


export default DS.Model.extend({
  userUsername: DS.attr('string'),
  created: DS.attr('date'),
  user: DS.belongsTo('user', { async: true }),

  trees: DS.hasMany('tree', { async: true }),
  treesCount: DS.attr('number'),
  sentences: DS.hasMany('sentence', { async: true }),
  sentencesCount: DS.attr('number'),
  reformulationsCount: DS.attr('number'),

  suggestionCredit: DS.attr('number'),
  nextCreditIn: DS.attr('number'),
  availableTreesCounts: DS.attr('object'),

  mothertongue: DS.attr('string'),
  trainedReformulations: DS.attr('boolean'),
  questionnaire: DS.belongsTo('questionnaire', { async: true }),
  questionnaireDone: DS.attr('boolean'),

  introducedExpHome: DS.attr('boolean'),
  introducedExpPlay: DS.attr('boolean'),
  introducedPlayHome: DS.attr('boolean'),
  introducedPlayPlay: DS.attr('boolean'),

  /*
   * Unused properties
   */
  url: DS.attr('string'),
  userUrl: DS.attr('string'),
  questionnaireUrl: DS.attr('string'),

  /*
   * Computed properties
   */
  lifecycle: Ember.inject.service(),
  availableTreesBucket: function() {
    var bucket = this.get('lifecycle.bucket');
    return this.get('availableTreesCounts')[bucket];
  }.property('lifecycle.bucket', 'availableTreesCounts')
});
