import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  /*
   * Global progress
   */
  updateCounts: function() {
    return this.get('currentProfile').reload();
  },

  /*
   * Suggestion actions
   */
  actions: {
    suggest: function() {
      this.sendStateEvent('suggest');
    },
    verify: function() {
      this.sendStateEvent('verify');
    },
    reset: function() {
      this.sendStateEvent('reset');
    }
  },

  /*
   * Suggestion FSM states and events
   */
  fsmStates: {
    initialState: 'suggesting'
  },
  fsmEvents: {
    suggest: {
      transition: { verified: 'suggesting' }
    },
    verify: {
      transition: {
        from: 'suggesting',
        to: 'verified',
        afterEvent: 'updateCounts'
      }
    },
    reset: {
      transition: {
        from: '$all',
        to: '$initial'
      }
    }
  }
});
