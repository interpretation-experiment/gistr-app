import Ember from 'ember';


export default Ember.Component.extend(Ember.FSM.Stateful, {

  /*
   * Task configuration
   */
  words: null,

  /*
   * Test actions
   */
  actions: {
    write: function() {
      this.sendStateEvent('write');
    },
    processTokens: function(tokens, finallyCallback) {
      var self = this,
          words = this.get('words'),
          length = Math.min(words.length, tokens.length),
          score = 0;

      for (var i = 0; i < length; i++) {
        score += words[i] === tokens[i];
      }

      this.sendAction('save', score === words.length, score, function() {
        self.sendStateEvent('reset');
        finallyCallback();
      });
    },
  },

  /*
   * FSM definition
   */
  fsmStates: {
    initialState: 'reading',
    knownStates: ['reading', 'writing', 'failed'],
  },
  fsmEvents: {
    write: {
      transition: { reading: 'writing' }
    },
    reset: {
      transition: { from: '$all', to: '$initial' }
    }
  },
});
