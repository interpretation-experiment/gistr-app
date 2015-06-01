import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import mean from 'gistr/utils/mean';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  shaping: Ember.inject.service(),

  /*
   * General tracking
   */
  words: null,
  span: null,
  scores: [],
  trial: 0,
  bumpTrial: function() {
    this.incrementProperty('trial');
  },
  trialWords: function() {
    var words = this.get('words');
    if (Ember.isNone(words)) { return; }
    return words[this.get('trial')];
  }.property('trial', 'words'),
  testProgress: function() {
    return 100 * this.get('trial') / this.get('shaping.readingSpanTrialsCount');
  }.property('trial', 'shaping.readingSpanTrialsCount'),
  reset: function() {
    this.setProperties({
      words: null,
      span: null,
      scores: [],
      trial: 0,
    });
  },

  /*
   * Test actions
   */
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
    processWords: function(userWords, finallyCallback) {
      var self = this,
          profile = this.get('currentProfile'),
          trialWords = this.get('trialWords'),
          scores = this.get('scores'),
          wordsCount = this.get('shaping.readingSpanWordsCount'),
          promise, span;

      var uniqueUserWords = [],
          lWord;
      for (var userWord of userWords) {
        lWord = userWord.toLowerCase();
        if (!uniqueUserWords.contains(lWord)) {
          uniqueUserWords.push(lWord);
        }
      }
      var intersection = uniqueUserWords.filter(function(userWord) {
        return trialWords.contains(userWord);
      });

      scores.push(intersection.length / wordsCount);

      if (this.get('trial') + 1 === this.get('shaping.readingSpanTrialsCount')) {
        // This is the last trial, save our results and finish
        span = mean(scores) * wordsCount;
        this.set('span', span);
        promise = this.get('store').createRecord('reading-span', {
          wordsCount: wordsCount,
          span: span
        }).save().then(function() {
          return profile.reload();
        }).then(function() {
          self.sendStateEvent('finish');
        });
      } else {
        // This isn't the last trial, keep going
        promise = this.sendStateEvent('read');
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
    knownStates: ['instructions', 'reading', 'distracting',
                  'writing', 'finished', 'failed'],
  },
  fsmEvents: {
    read: {
      transitions: [
        { instructions: 'reading' },
        {
          writing: 'reading',
          enter: 'bumpTrial'
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
        enter: 'bumpTrial'
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
