import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Service.extend(Ember.FSM.Stateful, SessionMixin, {
  /*
   * State pre-requisites definition and validation
   */
  requisites: {
    ground: {
      'is-logged-in': function(self) {
        return self.get('session.isAuthenticated') || !Ember.isNone(self.get('initializationProfile'));
      }
    },
    registering: {
      'has-username': function(self) {
        return !Ember.isNone(self.get('currentUser.username'));
      },
      'has-mothertongue': function(self) {
        return !Ember.isNone(self.get('currentProfile.mothertongue'));
      }
    },
    'exp.training': {
      'tested-read-write-speed': function(/*self*/) {
        // TODO: Check the read-write test is done
        return true;
      },
      'tested-memory-span': function(/*self*/) {
        // TODO: Check the memory-span test is done
        return true;
      },
      'answered-questionnaire': function(/*self*/) {
        // TODO: Check the questionnaire is done
        return true;
      },
      'completed-training': function(/*self*/) {
        // TODO: Check the training phase is completed
        return true;
      }
    },
    'exp.doing': {
      'completed-trials': function(/*self*/) {
        // TODO: Check the trials are completed
        return true;
      }
    },
    playing: {}
  },
  validateState: function() {
    var current = this.get('currentState');

    var checks = this.get('requisites')[current],
        errors = [];
    for (var name in checks) {
      if (!checks[name](this)) {
        errors.push(name);
      }
    }

    return {
      isComplete: errors.length === 0,
      errors: errors
    };
  },
  guardTransitionUp: function() {
    var validation = this.validateState();
    if (!validation.isComplete) {
      throw new Error("Current state is not complete. Missing " +
                      "items: " + validation.errors);
    }
  },
  //logState: function() {
    //console.log(this.get('currentState'));
  //},

  /*
   * Initialize and reset
   */
  initializationProfile: null,
  initialize: function(profile) {
    // Set the profile we're using (usually this happens before torii
    // has had time to set it system-wide)
    this.set('initializationProfile', profile);

    // Chain to the right state
    var transitions = this.get('fsmEvents.transitionsChain').copy().reverse(),
        self = this;
    var recurse = function() {
      if (transitions.length === 0) { return; }
      if (!self.validateState().isComplete) { return; }

      return self.sendStateEvent(transitions.pop()).then(recurse);
    };

    new Ember.RSVP.Promise(function(resolve) {
      resolve();
    }).then(recurse).then(function() {
      // Clear initialization profile
      self.set('initializationProfile', null);
    });
  },
  reset: function() {
    this.sendStateEvent('reset');
  },

  /*
   * FSM states and transitions
   */
  fsmStates: {
    initialState: 'ground',
    knownStates: ['ground', 'registering', 'exp.training', 'exp.doing', 'playing', 'failed'],
    //ground: { didEnter: 'logState' },
    //registering: { didEnter: 'logState' },
    //'exp.training': { didEnter: 'logState' },
    //'exp.doing': { didEnter: 'logState' },
    //playing: { didEnter: 'logState' }
  },
  fsmEvents: {
    transitionsChain: ['register', 'train', 'doexp', 'play'],
    register: { transition: { ground: 'registering', before: 'guardTransitionUp' } },
    train: { transition: { registering: 'exp.training', before: 'guardTransitionUp' } },
    doexp: { transition: { 'exp.training': 'exp.doing', before: 'guardTransitionUp' } },
    play: { transition: { 'exp.doing': 'playing', before: 'guardTransitionUp' } },
    reset: { transition: { '$all': '$initial' } }
  }
});
