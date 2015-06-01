import Ember from 'ember';

import LoadingSliderMixin from '../mixins/loading-slider';


export default Ember.Route.extend(LoadingSliderMixin, {
  lang: Ember.inject.service(),
  shaping: Ember.inject.service(),
  questionnaireChoices: Ember.inject.service(),

  /*
   * Hide tooltips when clicking anywhere, otherwise we get stuck
   * with some open tooltips that accumulate
   */
  tooltipDismissalEvent: 'click.tooltip-dismissal',
  initTooltipDismissal: function() {
    Ember.$(window).on(this.get('tooltipDismissalEvent'), function() {
      Ember.run.later(null, function() {
        Ember.$('.tooltip').hide();
      }, 200);
    });
  }.on('activate'),
  closeTooltipDismissal: function() {
    Ember.$(window).off(this.get('tooltipDismissalEvent'));
  }.on('deactivate'),

  beforeModel: function(/*transition*/) {
    // See if we're logged in, populate language support
    var self = this;
    return Ember.RSVP.all([
      self.get('session').fetch('spreadr').catch(function() {}),
      self.get('lang').populate(),
      self.get('shaping').populate(),
      self.get('questionnaireChoices').populate()
    ]);
  },

  actions: {
    logout: function(callback) {
      var self = this, promise;
      promise = this.get('session').close('spreadr').then(function() {
        self.transitionTo('index');
      });
      callback(promise);
    }
  }
});
