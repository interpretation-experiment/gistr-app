import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import draw from 'gistr/utils/draw';
import randint from 'gistr/utils/randint';
import countTokens from 'gistr/utils/count-tokens';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  lang: Ember.inject.service(),

  /*
   * Writing parameters
   */
  minTokens: 10,

  /*
   * Timing parameters
   */
  precision: 1,      // updates per second
  readFactor: 1,     // multiplied by the number of tokens, gives seconds
  writeFactor: 5,    // multiplied by the number of tokens, gives seconds
  readDuration: function() {
    return this.get('readFactor') * this.get('sentenceTokensCount');
  }.property('readFactor', 'sentenceTokensCount'),
  writeDuration: function() {
    return this.get('writeFactor') * this.get('sentenceTokensCount');
  }.property('readFactor', 'sentenceTokensCount'),

  /*
   * Global progress and reset
   */
  reset: function() {
    this.resetModels();
  },
  bailCheck: function() {
    var self = this;
    return this.get('currentProfile').reload().then(function(profile) {
      if (profile.get('availableMothertongueOtherawareTreesCount') === 0) {
        self.sendStateEvent('bail');
      }
    });
  },
  reloadTree: function() {
    return this.get('currentSentence.tree').then(function(tree) {
      return tree.reload();
    });
  },
  enoughSentencesForNextCredit: function() {
    return this.get('currentProfile.availableMothertongueOtherawareTreesCount') >= this.get('currentProfile.nextCreditIn');
  }.property('currentProfile.availableMothertongueOtherawareTreesCount', 'currentProfile.nextCreditIn'),

  /*
   * Current tree and sentence state and selection
   */
  currentSentence: null,
  sentenceTokensCount: function() {
    return countTokens(this.get('currentSentence.text'));
  }.property('currentSentence.text'),
  resetModels: function() {
    this.setProperties({
      currentSentence: null
    });
  },
  selectModels: function() {
    // FIXME: load X trees in one go in route's model hook
    var self = this, profile = this.get('currentProfile'),
        availableTreesCount = profile.get('availableMothertongueOtherawareTreesCount'),
        mothertongue = profile.get('mothertongue'),
        isOthertongue = mothertongue === this.get('lang.otherLanguage');

    return this.store.find('tree', {
      page_size: 1,
      page: randint(availableTreesCount) + 1,
      untouched_by_profile: profile.get('id'),
      root_language: isOthertongue ? this.get('lang.defaultLanguage') : mothertongue,
      with_other_mothertongue: isOthertongue,
      without_other_mothertongue: !isOthertongue
    }).then(function(trees) {
      return trees.objectAt(0).get('sentences');
    }).then(function(sentences) {
      self.set('currentSentence', draw(sentences));
    });
  },

  /*
   * Trial progress actions
   */
  actions: {
    init: function() {
      this.bailCheck();
    },
    read: function() {
      this.sendStateEvent('read');
    },
    hold: function() {
      this.sendStateEvent('hold');
    },
    write: function() {
      this.sendStateEvent('write');
    },
    timeout: function() {
      this.sendStateEvent('timeout');
    },
    verify: function() {
      this.sendStateEvent('verify');
    },
    reset: function() {
      this.sendStateEvent('reset');
    }
  },

  /*
   * Trial progress FSM states and events
   */
  fsmStates: {
    initialState: 'instructions',
    reading: {
      willEnter: 'selectModels'
    }
  },
  fsmEvents: {
    read: {
      transitions: {
        from: ['instructions', 'verified', 'timedout'],
        to: 'reading'
      }
    },
    hold: {
      transition: { reading: 'holding' }
    },
    write: {
      transition: { holding: 'writing' }
    },
    timeout: {
      transition: { writing: 'timedout' }
    },
    verify: {
      transition: {
        from: 'writing',
        to: 'verified',
        didEnter: 'reloadTree',
        afterEvent: 'bailCheck'
      }
    },
    bail: {
      transition: {
        from: ['instructions', 'verified'],
        to: 'empty'
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
