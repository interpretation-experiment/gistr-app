import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Service.extend(Ember.FSM.Stateful, SessionMixin, {
  log: function(text) {
    Ember.Logger.log('[lifecycle] ' + text);
  },

  shaping: Ember.inject.service(),

  subscribers: {},
  subscribe: function(route, obj) {
    this.log(`subscribe route '${route}'`);
    this.get('subscribers')[route] = obj;
  },
  unsubscribe: function(route) {
    this.log(`unsubscribe route '${route}'`);
    delete this.get('subscribers')[route];
  },

  /*
   * State item definition and validation
   */
  items: {
    ground: {
      'is-logged-in': {
        check: function(user) {
          this.log('check ground:is-logged-in');
          return !Ember.isNone(user);
        },
        route: 'login',
        observes: 'session.isAuthenticated'
      }
    },
    registering: {
      'has-username': {
        check: function(user) {
          this.log('check registering:has-username');
          return !Ember.isNone(user) && !Ember.isNone(user.get('username'));
        },
        route: 'profile',
        observes: 'currentUser.username'
      },
      'has-mothertongue': {
        check: function(user) {
          this.log('check registering:has-mothertongue');
          return !Ember.isNone(user) && !Ember.isNone(user.get('profile.mothertongue'));
        },
        route: 'profile',
        observes: 'currentProfile.mothertongue'
      }
    },
    'exp.training': {
      'tested-read-write-speed': {
        check: function(user) {
          // TODO: Check the read-write test is done
          return !Ember.isNone(user) && true;
        },
        route: 'profile',
        observes: null
      },
      'tested-memory-span': {
        check: function(user) {
          // TODO: Check the memory-span test is done
          return !Ember.isNone(user) && true;
        },
        route: 'profile',
        observes: null
      },
      'answered-questionnaire': {
        check: function(user) {
          // TODO: Check the questionnaire is done
          return !Ember.isNone(user) && true;
        },
        route: 'profile',
        observes: null
      },
      'completed-trials': {
        check: function(user) {
          this.log('check exp.training:completed-trials');
          return !Ember.isNone(user) && user.get('profile.trainedReformulations');
        },
        route: 'play',
        observes: 'currentProfile.trainedReformulations'
      }
    },
    'exp.doing': {
      'completed-trials': {
        check: function(user) {
          this.log('check exp.doing:completed-trials');
          return !Ember.isNone(user) && user.get('profile.reformulationsCount') >= this.get('shaping.experimentWork');
        },
        route: 'play',
        observes: 'currentProfile.reformulationsCount'
      }
    },
    playing: {
      'completed-trials': {
        check: function(user) {
          this.log('check playing:completed-trials');
          // This never ends
          return !Ember.isNone(user) && false;
        },
        route: 'play',
        observes: null
      }
    }
  },

  validator: Ember.Object.create({
    state: null,
    isComplete: null,
    pending: null,
    completed: null,
    actionRoutes: null
  }),

  validateState: function() {
    this.log('validating state');

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

    this.log(`pendings = ${pending}`);

    this.get('validator').setProperties({
      state: current,
      isComplete: pending.length === 0,
      pending: pending,
      completed: completed,
      actionRoutes: actionRoutes
    });

    return this.get('validator');
  },

  isAtOrAfter: function(ref) {
    var chain = this.get('statesChain');
    return chain.indexOf(this.get('currentState')) >= chain.indexOf(ref);
  },
  isAfter: function(ref) {
    var chain = this.get('statesChain');
    return chain.indexOf(this.get('currentState')) > chain.indexOf(ref);
  },

  /*
   * Transitioning
   */
  transitionUp: function() {
    this.log('transition up');

    var statesChain = this.get('statesChain'),
        transitionsChain = this.get('transitionsChain');

    var stateIndex = statesChain.indexOf(this.get('currentState'));
    return this.sendStateEvent(transitionsChain[stateIndex]);
  },
  guardTransitionUp: function() {
    this.log('guard transition up');

    var validator = this.get('validator');
    if (!validator.get('isComplete')) {
      throw new Error("Current state is not complete. Missing " +
                      "items: " + validator.get('pending'));
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
    this.log('currentState = ' + this.get('currentState'));
    this.log('bucket = ' + this.get('bucket'));
  },

  /*
   * Initialize and reset
   */
  initUser: null,
  initialize: function(initUser) {
    this.log('initialize');

    // Set the initUser we're using (usually this happens before torii
    // has had time to set it system-wide)
    this.set('initUser', initUser);

    // Chain down to the right state
    var transitions = this.get('transitionsChain').copy().reverse(),
        self = this;
    var recurse = function() {
      if (transitions.length === 0) { return; }
      // State has been revalidated as part of the transition
      if (!self.get('validator.isComplete')) { return; }

      return self.sendStateEvent(transitions.pop()).then(recurse);
    };

    return this.reset().then(recurse).then(function() {
      // Clear initialization profile
      self.set('initUser', null);
      // Start observing changes
      self.setupObservers();
    });
  },
  reset: function() {
    this.log('reset');

    this.removeObservers();
    this.set('observedCache', {});
    this.set('checksCache', {});
    return this.sendStateEvent('reset');
  },

  /*
   * Observer management
   */
  observedCache: {},
  checksCache: {},
  observedChanged: function(sender, key) {
    this.log(`(observedChanged) ${key}`);

    //
    // Check change of the observed property
    //
    var observedCache = this.get('observedCache'),
        observed = key,
        observedNew = this.get(observed),
        wasCached = observed in observedCache,
        observedPrev = observedCache[observed];

    this.log(`(observedChanged) observedNew = ${observedNew}`);
    observedCache[observed] = observedNew;

    // Ignore this if it was the first time the property was set
    if (!wasCached) {
      this.log('(observedChanged) first set of observed => aborting');
      return;
    } else {
      this.log(`(observedChanged) observedPrev = ${observedPrev}`);
    }

    // Ignore this if there was no value change
    if (observedNew === observedPrev) {
      this.log('(observedChanged) observedNew === observedPrev => aborting');
      return;
    }

    // Get affected checks
    var self = this,
        state = this.get('currentState'),
        stateChecks = this.get('items')[state];

    var changes = Object.keys(stateChecks).filter(function(checkName) {
      return (stateChecks[checkName].observes === observed &&
              self.checkHasChanged(stateChecks[checkName], checkName));
    });

    // Ignore this if there was no check change
    if (changes.length === 0) {
      this.log('(observedChanged) no check changes => aborting');
      return;
    } else {
      this.log(`(observedChanged) checks changed = ${changes}`);
    }

    //
    // Now we know we have a real change
    //

    // Revalidate state
    this.validateState();

    // Notify subscribers
    var subscribers = this.get('subscribers'),
        checksCache = this.get('checksCache'),
        stateCheck;
    changes.map(function(checkName) {
      stateCheck = stateChecks[checkName];
      if (stateCheck.route in subscribers) {
        subscribers[stateCheck.route].send('lifecycle.update', {
          name: checkName,
          value: checksCache[state][checkName]
        });
      }
    });
  },

  checkHasChanged: function(stateCheck, checkName) {
    //
    // See if the check has changed
    //
    var checksCache = this.get('checksCache'),
        state = this.get('currentState'),
        check = stateCheck.check,
        checkNew = Ember.run.bind(this, check)(this.get('currentUser')),
        checkPrev;

    if (!(state in checksCache)) {
      checksCache[state] = {};
    } else {
      checkPrev = checksCache[state][checkName];
    }
    checksCache[state][checkName] = checkNew;

    return checkNew !== checkPrev;
  },

  setupObservers: function() {
    this.log('setupObservers');

    var items = this.get('items'),
        state, observed;

    for (var stateName in items) {
      state = items[stateName];
      for (var checkName in state) {
        observed = state[checkName].observes;
        if (!Ember.isNone(observed)) {
          this.addObserver(observed, this, 'observedChanged');
        }
      }
    }
  },
  removeObservers: function() {
    this.log('removeObservers');

    var items = this.get('items'),
        state, observed;

    for (var stateName in items) {
      state = items[stateName];
      for (var checkName in state) {
        observed = state[checkName].observes;
        if (!Ember.isNone(observed)) {
          this.removeObserver(observed, this, 'observedChanged');
        }
      }
    }
  },

  /*
   * FSM states and transitions
   */
  statesChain: ['ground', 'registering', 'exp.training', 'exp.doing', 'playing'],
  fsmStates: {
    initialState: 'ground',
    knownStates: ['ground', 'registering', 'exp.training', 'exp.doing', 'playing', 'failed'],

    ground: { didEnter: 'logState' },
    registering: { didEnter: 'logState' },
    'exp.training': { didEnter: 'logState' },
    'exp.doing': { didEnter: 'logState' },
    playing: { didEnter: 'logState' }
  },
  transitionsChain: ['register', 'train', 'doexp', 'play'],
  fsmEvents: {
    register: { transition: { ground: 'registering', before: 'guardTransitionUp', after: 'validateState' } },
    train: { transition: { registering: 'exp.training', before: 'guardTransitionUp', after: 'validateState' } },
    doexp: { transition: { 'exp.training': 'exp.doing', before: 'guardTransitionUp', after: 'validateState' } },
    play: { transition: { 'exp.doing': 'playing', before: 'guardTransitionUp', after: 'validateState' } },
    reset: { transition: { '$all': '$initial', after: 'validateState' } }
  }
});
