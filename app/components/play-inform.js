import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import splitEvent from 'gistr/utils/split-event';
import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(SessionMixin, EnterNextMixin, {
  growl: Ember.inject.service(),
  lifecycle: Ember.inject.service(),

  isStaff: Ember.computed.alias('currentUser.isStaff'),
  hasCredit: Ember.computed.bool('currentProfile.suggestionCredit'),
  hasCreditOrIsStaff: Ember.computed.or('isStaff', 'hasCredit'),

  lastSentence: null,
  events: null,
  hasEvents: Ember.computed.notEmpty('events'),

  filterEvents: function(params) {
    var events = this.get('events');

    var optIncludes = function(part, param) {
      return part.includes(param) || Ember.isNone(param);
    };

    return events.filter(function(event) {
      var parts = splitEvent(event);
      return (optIncludes(parts.state, params.state) &&
              optIncludes(parts.type, params.type) &&
              optIncludes(parts.name, params.name));
    });
  },

  lifecycleEvent: function() {
    var events = this.filterEvents({ type: 'lifecycle' });
    if (events.length > 1) {
      throw new Error("Got more than one lifecycle event: " + events);
    }
    return events.objectAt(0);
  }.property('events'),

  rhythmEvents: function() {
    return this.filterEvents({ type: 'rhythm' });
  }.property('events'),
  hasRhythmEvents: Ember.computed.notEmpty('rhythmEvents'),
  hasExpDoingBreak: function() {
    var rhythmEvents = this.get('rhythmEvents');
    return rhythmEvents.contains('exp.doing:rhythm:break');
  }.property('rhythmEvents'),
  hasPlayingDiffBreak: function() {
    var rhythmEvents = this.get('rhythmEvents');
    return rhythmEvents.contains('playing:rhythm:diff-break');
  }.property('rhythmEvents'),
  hasPlayingExplorationBreak: function() {
    var rhythmEvents = this.get('rhythmEvents');
    return rhythmEvents.contains('playing:rhythm:exploration-break');
  }.property('rhythmEvents'),

  gainEvents: function() {
    return this.filterEvents({ type: 'gain' });
  }.property('events'),
  growlGains: function() {
    for (var event of this.get('gainEvents')) {
      // No other events than 'new-credit' for now
      if (splitEvent(event).name === 'new-credit') {
        this.get('growl').success(
          'New credit!',
          'You can suggest a new sentence by going to Home > New'
        );
      }
    }
  }.on('didInsertElement'),

  emptySentences: Ember.computed.equal('currentProfile.availableTreesBucket', 0),
  hasTransitioned: function() {
    var lifecycleEvent = this.get('lifecycleEvent');
    // Note that if this is false, then hasStateWorkLeft will be false
    // i.e. with event but not transitioned => no work left
    return !Ember.isNone(lifecycleEvent) && this.get('lifecycle.currentState') !== splitEvent(lifecycleEvent).state;
  }.property('lifecycle.currentState', 'lifecycleEvent'),
  hasStateWorkLeft: function() {
    return this.get('lifecycle.validator.actionRoutes').contains('play');
  }.property('lifecycle.validator.actionRoutes'),

  actions: {
    next: function() {
      this.sendAction("newTrial");
    },
    instruct: function() {
      console.log('inform instruct');
      this.sendAction('instruct');
    }
  }
});
