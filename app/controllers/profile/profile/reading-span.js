import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  shaping: Ember.inject.service(),

  words: null,
  trial: 0,
  trialWords: function() {
    var words = this.get('words');
    if (Ember.isNone(words)) { return; }
    return words[this.get('trial')];
  }.property('trial', 'words'),
  reset: function() {
    this.setProperties({
      words: null,
      trial: 0,
    });
  },

  actions: {
    read: function() {
      this.sendStateEvent('read');
    },
    distract: function() {
      this.sendStateEvent('distract');
    },
    write: function() {
      this.sendStateEvent('write');
    },
    processWords: function(words) {
      console.log(`Got words: ${words}`);
      if (this.get('trial') + 1 === this.get('shaping.readingSpanTrialsCount')) {
        // This is the last trial

        // TODO: save the model, and go to finish
      } else {
        // This isn't the last trial

        // TODO: save the results, and go to read
      }
    },
    reset: function() {
      this.sendStateEvent('reset');
    },
  },

  fsmStates: {
    initialState: 'instructions',
    knownStates: ['instructions', 'reading', 'distracting',
                  'writing', 'finished', 'failed'],
  },
  fsmEvents: {
    read: {
      transitions: [
        { instructions: 'reading' },
        {
          writing: 'reading',
          enter: 'bumpStreak'
        }
      ]
    },
    distract: {
      transition: { reading: 'distracting' }
    },
    write: {
      transition: { distracting: 'writing' }
    },
    finish: {
      transition: {
        writing: 'finished',
        enter: 'bumpStreak'
      }
    },
    reset: {
      transition: {
        from: '$all',
        to: '$initial',
        didEnter: 'reset'
      }
    }
  }
});
