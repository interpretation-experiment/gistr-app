import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import splitEvent from 'gistr/utils/split-event';
import CtrlEnterNextMixin from 'gistr/mixins/ctrl-enter-next';
import EventInformer from 'gistr/mixins/event-informer';
import ProlificMixin from 'gistr/mixins/prolific';


export default Ember.Component.extend(SessionMixin, CtrlEnterNextMixin,
                                      EventInformer, ProlificMixin, {
  growl: Ember.inject.service(),
  lifecycle: Ember.inject.service(),

  isStaff: Ember.computed.alias('currentUser.isStaff'),
  hasCredit: Ember.computed.bool('currentProfile.suggestionCredit'),
  hasCreditOrIsStaff: Ember.computed.or('isStaff', 'hasCredit'),

  lastSentence: null,
  events: null,
  actionRoute: 'play',

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

  onCtrlEnter: function() {
    this.$('#active-next').click();
  },
  actions: {
    next: function() {
      this.sendAction("newTrial");
    },
    instruct: function() {
      this.sendAction('instruct');
    }
  }
});
