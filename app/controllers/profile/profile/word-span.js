import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import mean from 'gistr/utils/mean';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  shaping: Ember.inject.service(),

  /*
   * Task configuration
   */
  words: null,
  sessionCounts: null,
  phaseCount: function() {
    return this.get('sessionCounts')[this.get('phase')];
  }.property('sessionCounts', 'phase'),

  /*
   * Task results
   */
  span: null,
  spanStats: {},
  score: 0,
  maxScore: function() {
    var words = this.get('words');
    if (Ember.isNone(words)) { return null; }

    var taskingWords = words['tasking'];
    return taskingWords.reduce((acc, trialWords) => acc + trialWords.length, 0);
  }.property('words'),
  pushSpanTrial: function(passed) {
    var setSize = this.get('trialWords.length'),
        stats = this.get('spanStats');
    if (setSize in stats) {
      stats[setSize].push(passed);
    } else {
      stats[setSize] = [passed];
    }
  },
  computeSpan: function() {
    var stats = this.get('spanStats'),
        setSizes = Object.keys(stats).sort().reverse(),
        threshold = 2/3,
        minTrials = 3,
        span;

    for (var size of setSizes) {
      // All sizes must have at least minTrials measures
      var nMeasures = stats[size].length;
      Ember.assert(nMeasures >= minTrials,
                  `Set size ${size} has only ${nMeasures} measures`);

      // Iterating in decreasing order, the last setSize to have
      // a mean >= threshold is our span
      if (mean(stats[size]) >= threshold) {
        span = size;
      }
    }

    this.set('span', span);
    return span;
  },

  /*
   * Status tracking
   */
  trial: 0,
  bumpTrial: function() {
    this.incrementProperty('trial');
  },
  resetTrial: function() {
    this.set('trial', 0);
  },

  phase: function() {
    var state = this.get('currentState');
    if (state === 'instructions' || state === 'training') {
      return 'training';
    } else {
      return 'tasking';
    }
  }.property('currentState'),
  isPhaseTraining: Ember.computed.equal('phase', 'training'),
  isPhaseTasking: Ember.computed.equal('phase', 'tasking'),
  sessionWords: function() {
    return (this.get('words') || {})[this.get('currentState')];
  }.property('words', 'currentState'),
  trialWords: function() {
    return (this.get('sessionWords') || {})[this.get('trial')];
  }.property('sessionWords', 'trial'),
  sessionProgress: function() {
    return 100 * this.get('trial') / this.get('phaseCount');
  }.property('trial', 'phaseCount'),
  reset: function() {
    this.setProperties({
      words: null,
      sessionCounts: null,
      span: null,
      spanState: {},
      score: 0,
      trial: 0,
    });
  },

  /*
   * Test actions
   */
  actions: {
    train: function() {
      this.sendStateEvent('train');
    },
    task: function() {
      this.sendStateEvent('task');
    },
    processTrial: function(passed, trialScore, finallyCallback) {
      var self = this,
          profile = this.get('currentProfile'),
          phaseCount = this.get('phaseCount'),
          lifecycle = this.get('lifecycle'),
          promise;

      if (this.get('currentState') === 'training') {
        if (this.get('trial') + 1 === phaseCount) {
          // It was the last training trial
          promise = this.sendStateEvent('start');
        } else {
          // This was a training trial, but not the last
          promise = this.sendStateEvent('train');
        }
      } else {
        // Save our score and span stats
        this.incrementProperty('score', trialScore);
        this.pushSpanTrial(passed);
        if (this.get('trial') + 1 === phaseCount) {
          // It was the last tasking trial
          this.computeSpan();
          promise = this.get('store').createRecord('word-span', {
            score: this.get('score'),
            span: this.get('span'),
          }).save().then(function() {
            return profile.reload();
          }).then(function() {
            // Transition lifecycle state if possible
            if (lifecycle.get('validator.isComplete')) {
              return lifecycle.transitionUp();
            }
          }).then(function() {
            self.sendStateEvent('finish');
          });
        } else {
          // This was a tasking trial, but not the last
          promise = this.sendStateEvent('task');
        }
      }

      promise.finally(finallyCallback);
    },
    reset: function() {
      this.sendStateEvent('reset');
    },
  },

  /*
   * FSM definition
   */
  fsmStates: {
    initialState: 'instructions',
    knownStates: ['instructions', 'training', 'starting',
                  'tasking', 'finished', 'failed']
  },
  fsmEvents: {
    train: {
      transitions: [
        { instructions: 'training' },
        { training: 'training', enter: 'bumpTrial' },
      ]
    },
    start: {
      transition: { training: 'starting', enter: 'resetTrial' }
    },
    task: {
      transitions: [
        { starting: 'tasking' },
        { tasking: 'tasking', enter: 'bumpTrial' }
      ]
    },
    finish: {
      transition: { tasking: 'finished', enter: 'bumpTrial' }
    },
    reset: {
      transition: { from: '$all', to: '$initial', didEnter: 'reset' }
    }
  },
});
