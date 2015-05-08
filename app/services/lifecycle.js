import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Service.extend(Ember.FSM.Stateful, SessionMixin, {
  shaping: Ember.inject.service(),

  /*
   * State pre-requisites definition and validation
   */
  requisites: {
    ground: {
      'is-logged-in': function(self, profile) {
        return !Ember.isNone(profile);
      }
    },
    registering: {
      'has-username': function(self, profile) {
        return !Ember.isNone(profile.get('user_username'));
      },
      'has-mothertongue': function(self, profile) {
        return !Ember.isNone(profile.get('mothertongue'));
      }
    },
    'exp.training': {
      'tested-read-write-speed': function(/*self, profile*/) {
        // TODO: Check the read-write test is done
        return true;
      },
      'tested-memory-span': function(/*self, profile*/) {
        // TODO: Check the memory-span test is done
        return true;
      },
      'answered-questionnaire': function(/*self, profile*/) {
        // TODO: Check the questionnaire is done
        return true;
      },
      'completed-training': function(self, profile) {
        return profile.get('trainedReformulations');
      }
    },
    'exp.doing': {
      'completed-trials': function(self, profile) {
        return profile.get('reformulationsCount') >= self.get('shaping.experimentWork');
      }
    },
    playing: {}
  },
  validateState: function() {
    // During initialization, torii has not yet had the time to publish the authentication
    // credentials system-wide, so we use the initializationProfile instead.
    var current = this.get('currentState'),
        profile = this.get('currentProfile') || this.get('initializationProfile');

    var checks = this.get('requisites')[current],
        errors = [];
    for (var name in checks) {
      if (!checks[name](this, profile)) {
        errors.push(name);
      }
    }

    return {
      state: current,
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
  isAtOrAfter: function(ref) {
    var chain = this.get('fsmStates.knownStates').slice(0, -1);
    return chain.indexOf(this.get('currentState')) >= chain.indexOf(ref);
  },
  buckets: [
    { label: 'Experiment', name: 'experiment' },
    { label: 'Game', name: 'game' }
  ],
  bucket: function() {
    if (this.isAtOrAfter('playing')) {
      return 'game';
    } else if (this.isAtOrAfter('exp.training')) {
      return 'experiment';
    } else {
      return null;
    }
  }.property('currentState'),
  logState: function() {
    console.log("Current state: " + this.get('currentState'));
    console.log("Current bucket: " + this.get('bucket'));
  },

  /*
   * Initialize and reset
   */
  initializationProfile: null,
  initialize: function(profile) {
    // Set the profile we're using (usually this happens before torii
    // has had time to set it system-wide)
    this.set('initializationProfile', profile);

    // Chain down to the right state
    var transitions = this.get('fsmEvents.transitionsChain').copy().reverse(),
        self = this;
    var recurse = function() {
      if (transitions.length === 0) { return; }
      if (!self.validateState().isComplete) { return; }

      return self.sendStateEvent(transitions.pop()).then(recurse);
    };

    return new Ember.RSVP.Promise(function(resolve) {
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

    ground: { didEnter: 'logState' },
    registering: { didEnter: 'logState' },
    'exp.training': { didEnter: 'logState' },
    'exp.doing': { didEnter: 'logState' },
    playing: { didEnter: 'logState' }
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
