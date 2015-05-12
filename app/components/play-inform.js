import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import splitEvent from 'gistr/utils/split-event';


export default Ember.Component.extend(SessionMixin, {
  growl: Ember.inject.service(),
  lifecycle: Ember.inject.service(),

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
  }.property(),

  rhythmEvents: function() {
    return this.filterEvents({ type: 'rhythm' });
  }.property(),
  hasRhythmEvents: Ember.computed.notEmpty('rhythmEvents'),
  hasExpDoingBreak: function() {
    var rhythmEvents = this.get('rhythmEvents');
    return rhythmEvents.indexOf('exp.doing:rhythm:break') !== -1;
  }.property('rhythmEvents'),
  hasPlayingDiffBreak: function() {
    var rhythmEvents = this.get('rhythmEvents');
    return rhythmEvents.indexOf('playing:rhythm:diff-break') !== -1;
  }.property('rhythmEvents'),
  hasPlayingExplorationBreak: function() {
    var rhythmEvents = this.get('rhythmEvents');
    return rhythmEvents.indexOf('playing:rhythm:exploration-break') !== -1;
  }.property('rhythmEvents'),

  gainEvents: function() {
    return this.filterEvents({ type: 'gain' });
  }.property(),
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
  stateValidation: function() {
    return this.get('lifecycle').validateState();
  }.property(),
  hasTransitioned: function() {
    var lifecycleEvent = this.get('lifecycleEvent');
    // Note that if this is false, then hasStateWorkLeft will be false
    // i.e. with event but not transitioned => no work left
    return this.get('lifecycle.currentState') !== splitEvent(lifecycleEvent).state;
  }.property('lifecycle.currentState', 'lifecycleEvent'),
  hasStateWorkLeft: function() {
    return this.get('stateValidation').actionRoutes.indexOf('play') !== -1;
  }.property('stateValidation'),

  actions: {
    next: function() {
      this.sendAction("newTrial");
    }
  }
});
