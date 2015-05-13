import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Service.extend(Ember.FSM.Stateful, SessionMixin, {
  shaping: Ember.inject.service(),

  /*
   * State item definition and validation
   */
  items: {
    ground: {
      'is-logged-in': {
        check: function(user) {
          return !Ember.isNone(user);
        },
        route: 'login'
      }
    },
    registering: {
      'has-username': {
        check: function(user) {
          return !Ember.isNone(user.get('username'));
        },
        route: 'profile'
      },
      'has-mothertongue': {
        check: function(user) {
          return !Ember.isNone(user.get('profile.mothertongue'));
        },
        route: 'profile'
      }
    },
    'exp.training': {
      'tested-read-write-speed': {
        check: function(/*user*/) {
          // TODO: Check the read-write test is done
          return true;
        },
        route: 'profile',
      },
      'tested-memory-span': {
        check: function(/*user*/) {
          // TODO: Check the memory-span test is done
          return true;
        },
        route: 'profile'
      },
      'answered-questionnaire': {
        check: function(/*user*/) {
          // TODO: Check the questionnaire is done
          return true;
        },
        route: 'profile'
      },
      'completed-trials': {
        check: function(user) {
          return user.get('profile.trainedReformulations');
        },
        route: 'play'
      }
    },
    'exp.doing': {
      'completed-trials': {
        check: function(user) {
          return user.get('profile.reformulationsCount') >= this.get('shaping.experimentWork');
        },
        route: 'play'
      }
    },
    playing: {
      'completed-trials': {
        check: function(/*user*/) {
          // This never ends
          return false;
        },
        route: 'play'
      }
    }
  },

  validateState: function() {
    // During initialization, torii has not yet had the time to publish the authentication
    // credentials system-wide, so we use the initUser instead.
    var current = this.get('currentState'),
        user = this.get('currentUser') || this.get('initUser');

    var items = this.get('items')[current],
        pending = [],
        completed = [],
        actionRoutes = [],
        item;
    for (var name in items) {
      item = items[name];
      if (!Ember.run.bind(this, item.check)(user)) {
        pending.push(name);
        if (!actionRoutes.contains(item.route)) { actionRoutes.push(item.route); }
      } else {
        completed.push(name);
      }
    }

    return {
      state: current,
      isComplete: pending.length === 0,
      pending: pending,
      completed: completed,
      actionRoutes: actionRoutes
    };
  },

  isAtOrAfter: function(ref) {
    var chain = this.get('fsmStates.knownStates').slice(0, -1);
    return chain.indexOf(this.get('currentState')) >= chain.indexOf(ref);
  },

  /*
   * Transitioning
   */
  transitionUp: function() {
    var statesChain = this.get('fsmStates.knownStates'),
        transitionsChain = this.get('fsmEvents.transitionsChain');

    var stateIndex = statesChain.indexOf(this.get('currentState'));
    this.sendStateEvent(transitionsChain[stateIndex]);
  },
  guardTransitionUp: function() {
    var validation = this.validateState();
    if (!validation.isComplete) {
      throw new Error("Current state is not complete. Missing " +
                      "items: " + validation.pending);
    }
  },

  /*
   * Sentence buckets
   */
  buckets: [
    { label: 'Training', name: 'training' },
    { label: 'Experiment', name: 'experiment' },
    { label: 'Game', name: 'game' }
  ],
  bucketMap: {
    'exp.training': 'training',
    'exp.doing': 'experiment',
    'playing': 'game'
  },
  bucket: function() {
    return this.get('bucketMap')[this.get('currentState')];
  }.property('currentState'),

  logState: function() {
    console.log("Current state: " + this.get('currentState'));
    console.log("Current bucket: " + this.get('bucket'));
  },

  /*
   * Initialize and reset
   */
  initUser: null,
  initialize: function(initUser) {
    // Set the initUser we're using (usually this happens before torii
    // has had time to set it system-wide)
    this.set('initUser', initUser);

    // Chain down to the right state
    var transitions = this.get('fsmEvents.transitionsChain').copy().reverse(),
        self = this;
    var recurse = function() {
      if (transitions.length === 0) { return; }
      if (!self.validateState().isComplete) { return; }

      return self.sendStateEvent(transitions.pop()).then(recurse);
    };

    return this.reset().then(recurse).then(function() {
      // Clear initialization profile
      self.set('initUser', null);
    });
  },
  reset: function() {
    return this.sendStateEvent('reset');
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
